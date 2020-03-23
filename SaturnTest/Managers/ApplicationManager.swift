//
//  ApplicationManager.swift
//  SaturnTest
//
//  Created by Bryan Gula on 3/22/20.
//  Copyright © 2020 Bryan Gula. All rights reserved.
//

import Foundation
import UIKit

public final class ApplicationManager: NSObject, UIWindowSceneDelegate {
    
    public var window: UIWindow?
    
    public var notesManager = NotesManager()
    
    init(window: UIWindow?) {
        
        self.window = window
        
        let nav = BaseNavigationController(rootViewController: NotesViewController(manager: notesManager))
        nav.navigationBar.tintColor = .white
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
    }
}
