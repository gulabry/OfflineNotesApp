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

public final class OfflineManager {
    
    private let reachability = NetworkReachabilityManager(host: "www.google.com")
    private var status: NetworkReachabilityManager.NetworkReachabilityStatus = .unknown
    
    public var isConnected: Bool {
        return status == .reachable(.cellular) || status == .reachable(.ethernetOrWiFi)
    }
    
    init() {
        
        Threading.realmQueue.async {
            
            let config = Realm.Configuration(
                schemaVersion: 1,
                migrationBlock: { migration, oldSchemaVersion in
                })

            Realm.Configuration.defaultConfiguration = config
            _ = try! Realm()
            print(Realm.Configuration.defaultConfiguration.fileURL!)
        }
        
        reachability?.startListening(onUpdatePerforming: { status in
            self.status = status
        })
    }
    
    public func loadSavedNotes(completion: @escaping ([Note])->()) {
        Threading.realmQueue.async {
            let realm = try! Realm()
            completion(Array(realm.objects(Note.self)))
        }
    }
    
    //  returns result of saving note in Realm
    //  and saving Image in SDImageCache
    //
    public func addLocal(note: Note, image: UIImage, completion: @escaping (Bool) -> ()) {
        
        let scaledDownImage = UIImage(data: image.jpegData(compressionQuality: 0.2)!)
        Threading.realmQueue.async {
            let key = note.localId
            SDImageCache.shared.store(scaledDownImage,
                                      forKey: key,
                                      toDisk: true) {
                Threading.realmQueue.async {
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(note)
                        completion(true)
                    }
                }
            }
        }
    }
    
    public func update(note: Note, with remoteNote: NoteUploadResponse) {
        Threading.realmQueue.async {
            let realm = try! Realm()
            try! realm.write {
                note.id = remoteNote.id
            }
        }
    }
    
    public func update(note: Note, imageId: String) {
        Threading.realmQueue.async {
            let realm = try! Realm()
            try! realm.write {
                note.imageId = imageId
            }
        }
    }
}
