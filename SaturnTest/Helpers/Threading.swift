//
//  Threading.swift
//  SaturnTest
//
//  Created by Bryan Gula on 3/22/20.
//  Copyright © 2020 Bryan Gula. All rights reserved.
//

import Foundation

public class Threading {
    
    public static func mainAfter(seconds: Double, _ block: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: block)
    }
    
    public static func main(_ block: @escaping () -> Void) {
        DispatchQueue.main.async(execute: block)
    }
    
    public static func requireMain(_ block: @escaping () -> Void) {
        if !Thread.isMainThread {
            DispatchQueue.main.async(execute: block)
        } else {
            block()
        }
    }
    
    public static func inBackgroundUserInitiated(block: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            block()
        }
    }
    
    public static func inBackground(block: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            block()
        }
    }
    
    public static func onMainAfter(seconds: Double, block: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            block()
        }
    }
        
    public static func onBackgroundAfter(seconds: Double, block: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + seconds) {
            block()
        }
    }
}
