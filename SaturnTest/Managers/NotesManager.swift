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
    
    public init() {
        
        offlineManager.loadSavedNotes(completion: { [weak self] (notes) in
            self?.delegate?.didUpdate(notes: notes)
        })
    }
    
    //  the modals will indicated if they are saved locally or not
    //  note.id = saved remotely
    //  note.localId = saved locally
    //  note.imageId = saved remotely
    //  note.imageLocalId = saved locally
    //
    public func save(note: Note, image: UIImage) {
        
        if note.isSynced {
            print("note is synced with server")
            return
        }
        
        offlineManager.addLocal(note: note, image: image) { [weak self] isSavedLocally in
            if isSavedLocally {
                print("saved locally")
                self?.addRemote(note: note, image: image)
            } else {
                print("note failed to add locally")
            }
        }
    }
    
    public func retryUploadingNote(_ note: Note) {
        guard let image = SDImageCache.shared.imageFromCache(forKey: note.imageLocalId) else { return }
        save(note: note, image: image)
    }
    
    //  Will attempt to add the image first, then upload the note
    //
    public func addRemote(note: Note, image: UIImage) {
        
        //  first adding image to note
        //
        attemptUploadImage(image, to: note) { [weak self] success in
            if success {
                //  update modal and status
                //  note has been uploaded
                print("image uploaded")
                
                Threading.main {
                    self?.attemptUploadNote(note) { success in
                        if success {
                            print("added note remotely")
                            self?.delegate?.didUpload(note: note)
                        } else {
                            self?.offlineManager.addToRetryQueue(note: note)
                        }
                    }
                }
                
            } else {
                print("failed to add image remotely, requeuing")
                self?.offlineManager.addToRetryQueue(note: note)
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
}
