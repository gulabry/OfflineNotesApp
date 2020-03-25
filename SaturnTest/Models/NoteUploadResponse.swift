//
//  NoteUploadResponse.swift
//  SaturnTest
//
//  Created by Bryan Gula on 3/23/20.
//  Copyright © 2020 Bryan Gula. All rights reserved.
//

import Foundation

public struct NoteUploadResponse: Decodable {
    
    var id: Int
    var title: String
    var image: NoteUploadImageResponse?
    
    public struct NoteUploadImageResponse: Decodable {
        
        var id: String
        var urls: NoteUploadImageURLs
        
        public struct NoteUploadImageURLs: Decodable {
            var small: String?
            var medium: String?
            var large: String?
        }
    }
}
