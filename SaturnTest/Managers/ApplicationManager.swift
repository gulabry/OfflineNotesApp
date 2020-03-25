//
//  ApplicationManager.swift
//  SaturnTest
//
//  Created by Bryan Gula on 3/22/20.
//  Copyright © 2020 Bryan Gula. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import RealmSwift

public final class ApplicationManager: NSObject, UIWindowSceneDelegate {
    
    public var window: UIWindow?
    
    public lazy var notesManager: NotesManager = {
        let manager = NotesManager(fetchNotes: isConnected)
        return manager
    }()
    
    private let reachability = NetworkReachabilityManager(host: "www.google.com")
    private var status: NetworkReachabilityManager.NetworkReachabilityStatus = .unknown
    
    public var isConnected: Bool {
        return status == .reachable(.cellular) || status == .reachable(.ethernetOrWiFi)
    }
    
    private var uploadQueue: OperationQueue {
        let queue = OperationQueue()
        return queue
    }
    
    init(window: UIWindow?) {
        
        self.window = window
        super.init()
        
        let nav = BaseNavigationController(rootViewController: NotesViewController(manager: notesManager))
        nav.navigationBar.tintColor = .white
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
        
        registerNetworkChanges()
    }

    func registerNetworkChanges() {
        reachability?.startListening(onUpdatePerforming: { status in
            self.status = status
            
            if self.isConnected {
                self.retryFailedUploads()
            }
        })
    }
    
    //  Manage Offline Objects and Retry Uploads
    
    public func retryFailedUploads() {
        Threading.realmQueue.async {
            let realm = try! Realm()
            let notes = Array(realm.objects(Note.self)).filter { $0.id == 0 }
        
            for note in notes {
                self.uploadQueue.addOperation(NoteUploadOperation(note: note, manager: self.notesManager))
            }
        }
    }
}
