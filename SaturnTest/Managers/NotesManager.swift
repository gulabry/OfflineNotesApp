//
//  NotesManager.swift
//  SaturnTest
//
//  Created by Bryan Gula on 3/22/20.
//  Copyright © 2020 Bryan Gula. All rights reserved.
//

import Foundation
import Alamofire

enum NetworkStatus {
    case online
    case offline
}

protocol NotesManagerDelegate: NSObject {
    func updated(notes: [Note])
}

public final class NotesManager {
    
    private let offlineManager = OfflineManager()
    
    private let manager = NetworkReachabilityManager(host: "www.google.com")
    
    public init() {
        
        manager?.startListening { [weak self] status in
            print("Network Status Changed: \(status)")
        }
    }
    
    public func save(note: Note, imageData: Data) {
        print("save note")
        
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
