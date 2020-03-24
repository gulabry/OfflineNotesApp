//
//  Note.swift
//  SaturnTest
//
//  Created by Bryan Gula on 3/22/20.
//  Copyright © 2020 Bryan Gula. All rights reserved.
//

import Foundation
import RealmSwift

public class Note: Object {
    @objc dynamic var id = 0
    @objc dynamic var localId = ""
    @objc dynamic var imageId = ""
    @objc dynamic var imageLocalId = ""
    @objc dynamic var body = ""
    //@objc dynamic var isAdding = false
}

public extension Note {
    var isImageSynced: Bool {
        return imageId.count > 0
    }
    
    var isSynced: Bool {
        return isImageSynced && id != 0
    }
}

public struct NoteUpload: Codable {
    var title: String
    var image_id: String
}
