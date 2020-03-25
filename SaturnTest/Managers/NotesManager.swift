//
//  NotesManager.swift
//  SaturnTest
//
//  Created by Bryan Gula on 3/22/20.
//  Copyright © 2020 Bryan Gula. All rights reserved.
//

import Foundation
import Alamofire
import SDWebImage
import RealmSwift

public protocol NotesManagerDelegate: NSObject {
    func didUpdate(notes: [Note])
    func didUpload(note: Note)
}

public final class NotesManager {
    
    private let offlineManager = OfflineManager()
    public weak var delegate: NotesManagerDelegate?

    //  source of truth (TM)
    //
    //internal var notes: [Note]
    
    public init(fetchNotes: Bool) {
        if fetchNotes {
            self.fetchNotes { [weak self] notes in
                guard let notes = notes else { return }
                self?.delegate?.didUpdate(notes: notes)
            }
        } else {
            offlineManager.loadSavedNotes { [weak self] notes in
                self?.delegate?.didUpdate(notes: notes)
            }
        }
    }
    
    public func save(note: Note, image: UIImage) {
        
        if note.isSynced {
            print("note is already with server")
            note.stopAdding()
            self.delegate?.didUpload(note: note)
            return
        }
        
        offlineManager.addLocal(note: note, image: image) { [weak self] isSavedLocally in
            guard let self = self else { return }
            if isSavedLocally && self.offlineManager.isConnected {
                print("saved locally")
                self.addRemote(note: note, image: image)
            } else {
                print("note failed to add locally, or is offline")
                note.stopAdding()
                self.delegate?.didUpload(note: note)
            }
        }
    }
    
    public func retryUploadingNote(_ note: Note) {
        guard let image = SDImageCache.shared.imageFromCache(forKey: note.localId) else { return }
        save(note: note, image: image)
    }
    
    //  Will attempt to add the image first, then upload the note
    //
    public func addRemote(note: Note, image: UIImage, completion: (() -> ())? = nil) {
        
        //  first adding image to note
        //
        attemptUploadImage(image, to: note) { [weak self] success in
            
            note.stopAdding()

            if success {
                //  update modal and status
                //  note has been uploaded
                print("image uploaded")
                
                Threading.main {
                    self?.attemptUploadNote(note) { success in

                        if success {
                            print("added note remotely")
                        }
                        
                        self?.delegate?.didUpload(note: note)
                    }
                }
                
            } else {
                print("failed to add image remotely, requeuing")
                self?.delegate?.didUpload(note: note)
            }
        }
    }
    
    private func attemptUploadImage(_ image: UIImage, to note: Note, completion: @escaping (Bool) -> ()) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.2) else { completion(false); return }
        
        // if fails add note ID to local storage of note local ids to retry (these have local imageIDs)
        //
        NotesManager.uploadImage(data: imageData) { response in
            switch response {
            case .success(let addedImage):
                self.offlineManager.update(note: note, imageId: addedImage.id)
                completion(true)
            case .failure(let error):
                print(error.localizedDescription)
                completion(false)
            }
        }
    }
    
    private func attemptUploadNote(_ note: Note, completion: @escaping (Bool) -> ()) {
        
        NotesManager.uploadNote(note) { response in
            switch response {
            case .success(let addedNote):
                self.offlineManager.update(note: note, with: addedNote)
                completion(true)
            case .failure(let error):
                print(error.localizedDescription)
                completion(false)
            }
        }
    }
    
    private func fetchNotes(completion: @escaping ([Note]?) -> ()) {
        NotesManager.getNotes { response in
            switch response {
            case .success(let remoteNotes):
                self.convertRemoteNotesResponse(remoteNotes) { notes in
                    completion(notes)
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
    
    private func convertRemoteNotesResponse(_ remoteNotes: [NoteUploadResponse], completion: @escaping ([Note]) -> ()) {
        Threading.realmQueue.async {
            let realm = try! Realm()
            let savedNotes = realm.objects(Note.self)

            var newNotes = [Note]()
            
            for note in remoteNotes {
                //  if match does not exist, add new note
                if Array(savedNotes).filter({ $0.id == note.id }).first == nil {
                    print("new note added from remote")
                    let newNote = Note()
                    newNote.id = note.id
                    newNote.body = note.title
                    if let image = note.image {
                        newNote.imageId = image.id
                        newNote.imageURLString = image.urls.small ?? ""
                    }
                    newNotes.append(newNote)
                }
            }
            
            try! realm.write {
                realm.add(newNotes)
                completion(Array(realm.objects(Note.self)))
            }
        }
    }
}

//  API functions
//
extension NotesManager {
    
    static func uploadNote(_ note: Note, completion: @escaping (Result<NoteUploadResponse, AFError>) -> ()) {
        guard let url = URL(string: "https://env-develop.saturn.engineering/api/v2/test-notes") else { return }
    
        AF.request(url,
                   method: .post,
                   parameters: NoteUpload(title: note.body, image_id: note.imageId),
                   encoder: JSONParameterEncoder.default).responseDecodable(of: NoteUploadResponse.self, queue: DispatchQueue.global(qos: .utility), decoder: JSONDecoder()) { response in
                    completion(response.result)
        }
    }

    static func uploadImage(data: Data, completion: @escaping (Result<ImageUploadResponse, AFError>) -> ()) {
        guard let url = URL(string: "https://env-develop.saturn.engineering/api/v2/test-notes/photo"),
            let request = try? URLRequest(url: url, method: .post) else { return }
                
        AF.upload(multipartFormData: { (multipart) in
            multipart.append(data, withName: "file", fileName: "file.jpg", mimeType: "image/jpg")
        }, with: request).responseDecodable(of: ImageUploadResponse.self,
                                            queue: DispatchQueue.global(qos: .utility),
                                            decoder: JSONDecoder()) { response in
            completion(response.result)
        }
    }
    
    static func getNotes(completion: @escaping (Result<[NoteUploadResponse], AFError>) -> ()) {
        guard let url = URL(string: "https://env-develop.saturn.engineering/api/v2/test-notes") else { return }
    
        AF.request(url).responseDecodable(of: [NoteUploadResponse].self,
                                          queue: DispatchQueue.global(qos: .utility),
                                          decoder: JSONDecoder()) { response in
            completion(response.result)
        }
    }
}
