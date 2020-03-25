//
//  Note.swift
//  SaturnTest
//
//  Created by Bryan Gula on 3/22/20.
//  Copyright © 2020 Bryan Gula. All rights reserved.
//

import Foundation
import RealmSwift

public class Note: Object, Codable {
    @objc dynamic var id = 0
    @objc dynamic var localId = ""
    @objc dynamic var imageId = ""
    @objc dynamic var imageLocalId = ""
    @objc dynamic var imageURLString = ""
    @objc dynamic var body = ""
    @objc dynamic var isAdding = false
}

public extension Note {
    var isImageSynced: Bool {
        return imageId.count > 0
    }
    
    var isSynced: Bool {
        return id != 0
    }
    
    func stopAdding() {
        Threading.realmQueue.async {
            let realm = try! Realm()
            try! realm.write {
                self.isAdding = false
            }  
        }
    }
    
    func startSyncing(_ completion: @escaping () -> ()) {
        Threading.main {
            let realm = try! Realm()
            try! realm.write {
                self.isAdding = true
                completion()
            }
        }
    }
}

public struct NoteUpload: Codable {
    var title: String
    var image_id: String
}
