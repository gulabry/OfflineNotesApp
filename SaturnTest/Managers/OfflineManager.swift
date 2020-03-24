//
//  OfflineManager.swift
//  SaturnTest
//
//  Created by Bryan Gula on 3/22/20.
//  Copyright © 2020 Bryan Gula. All rights reserved.
//

import Foundation
import RealmSwift
import SDWebImage
import Alamofire

public typealias NoteLocalID = String
fileprivate var FailedUploadKey = "kFailedUploads"

public final class OfflineManager {
    
    public var realmQueue = DispatchQueue.main
    
    private var failedUploads: [NoteLocalID] {
        get { return UserDefaults.standard.value(forKey: FailedUploadKey) as? [String] ?? [String]() }
        set { UserDefaults.standard.setValue(newValue, forKey: FailedUploadKey) }
    }
    
    init() {
        
        realmQueue.async {
            
            let config = Realm.Configuration(
                schemaVersion: 1,
                migrationBlock: { migration, oldSchemaVersion in
                })

            Realm.Configuration.defaultConfiguration = config
            _ = try! Realm()
            print(Realm.Configuration.defaultConfiguration.fileURL!)
        }
    }
    
    public func loadSavedNotes(completion: @escaping ([Note])->()) {
        realmQueue.async {
            let realm = try! Realm()
            completion(Array(realm.objects(Note.self)))
        }
    }
    
    //  returns result of saving note in Realm
    //  and saving Image in SDImageCache
    //
    public func addLocal(note: Note, image: UIImage, completion: @escaping (Bool) -> ()) {
        
        let scaledDownImage = UIImage(data: image.jpegData(compressionQuality: 0.2)!)
        realmQueue.async {
            let key = note.localId.isEmpty ? note.imageId : note.localId
            SDImageCache.shared.store(scaledDownImage,
                                      forKey: key,
                                      toDisk: true) { [weak self] in
                                        self!.realmQueue.async {
                                            let realm = try! Realm()
                                            try! realm.write {
                                                realm.add(note)
                                            }
                                        
                                            completion(true)
                                        }
            }
        }
    }
    
    public func update(note: Note, with remoteNote: NoteUploadResponse) {
        realmQueue.async {
            let realm = try! Realm()
            try! realm.write {
                note.id = remoteNote.id
            }
        }
    }
    
    public func update(note: Note, imageId: String) {
        realmQueue.async {
            let realm = try! Realm()
            try! realm.write {
                note.imageId = imageId
            }
        }
    }
    
    //  Manage Offline Objects and Retry Uploads
    
    public func addToRetryQueue(note: Note) {
        realmQueue.async {
            self.failedUploads.append(note.localId)
        }
    }
}
