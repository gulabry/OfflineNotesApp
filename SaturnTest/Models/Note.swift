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
    @objc dynamic var id = ""
    @objc dynamic var localId = ""
    @objc dynamic var imageId = ""
    @objc dynamic var imageLocalId = ""
    @objc dynamic var body = ""
}
