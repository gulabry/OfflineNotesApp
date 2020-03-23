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
    
    private let realm: Realm
    private let reachability = NetworkReachabilityManager(host: "www.google.com")
    
    private var failedUploads: [NoteLocalID] {
        get { return UserDefaults.standard.value(forKey: FailedUploadKey) as? [String] ?? [String]() }
        set { UserDefaults.standard.setValue(newValue, forKey: FailedUploadKey) }
    }
    
    init() {
        do {
            try self.realm = Realm()
        } catch let error as NSError {
            fatalError(error.debugDescription)
        }
        registerNetworkChanges()
    }
    
    public func loadSavedNotes() -> [Note] {
        return Array(realm.objects(Note.self))
    }
    
    func registerNetworkChanges() {
        reachability?.startListening { status in
            print("Network Status Changed: \(status)")
        }
    }
    
    //  returns result of saving note in Realm
    //  and saving Image in SDImageCache
    //
    public func addLocal(note: Note, image: UIImage, completion: @escaping (Bool) -> ()) {
        
        let scaledDownImage = UIImage(data: image.jpegData(compressionQuality: 0.3)!)

        SDImageCache.shared.store(scaledDownImage,
                                  forKey: note.localId.isEmpty ? note.imageId : note.localId,
                                  toDisk: true) { [weak self] in
            
            guard let self = self else { return }
            do {
                try self.realm.write {
                    self.realm.add(note)
                }
            } catch let error {
                print(error)
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    public func addRemote(note: Note, image: UIImage) {
        
    }
    
    private func addRemoteWithHandler(note: Note, image: UIImage, completion: @escaping (Bool) -> ()) {
        
        // if fails add note ID to local storage of note local ids to retry (these have local imageIDs)
        //
    }
}
