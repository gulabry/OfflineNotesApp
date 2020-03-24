//
//  ImageUploadResponse.swift
//  SaturnTest
//
//  Created by Bryan Gula on 3/23/20.
//  Copyright © 2020 Bryan Gula. All rights reserved.
//

import Foundation

public struct ImageUploadResponse: Decodable {
    var id: String
    var image_type: String
}
