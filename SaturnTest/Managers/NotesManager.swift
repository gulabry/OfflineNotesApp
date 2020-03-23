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
    func notesDidUpdate(notes: [Note])
}

public final class NotesManager {
    
    private let offlineManager = OfflineManager()
    public weak var delegate: NotesManagerDelegate?

    //  source of truth (TM)
    //
    internal var notes: [Note]
    
    public init() {
        notes = offlineManager.loadSavedNotes()
    }
    
    //  the modals will indicated if they are saved locally or not
    //  note.id = saved remotely
    //  note.localId = saved locally
    //  note.imageId = saved remotely
    //  note.imageLocalId = saved locally
    //
    public func save(note: Note, image: UIImage) {
        print("save note")
        
        offlineManager.addLocal(note: note, image: image) { [weak self] isSavedLocally in
            if isSavedLocally {
                // start online upload
                print("saved locally")
                //self?.delegate?.noteLocallyAdded(note: note)
                
            } else {
                // add id to failed queue.. local
            }
        }
        // save image locally
        // save note localling with imageURL
        
        // upload image
        // attach image ID and upload note
    }
    
    func uploadData(data: Data, completion: @escaping (DataResponse<Any, Error>) -> ()) throws {
        guard let url = URL(string: "https://env-develop.saturn.engineering/api/v2/test-notes/photo") else { return }
        let headers: [String: String] = [:]
//        Alamofire.upload(multipartFormData: { (multipart) in
//            multipart.append(data, withName: "file", fileName: "file.jpg", mimeType: "image/jpg")
//        }, usingThreshold: UInt64(), to: url, method: .post, headers: headers, queue: nil) { (result) in
//            switch result {
//            case .success(let response, _, _):
//                response.responseJSON { (data) in
//                    print(data)
//                }
//            case .failure(_):
//                print("Failed")
//            }
//        }
        
        let request = try URLRequest(url: url, method: .post)
                
        AF.upload(multipartFormData: { (multipart) in
            multipart.append(data, withName: "file", fileName: "file.jpg", mimeType: "image/jpg")
        }, with: request).response { response in
            print(response.response?.statusCode)
        }
    }
}
