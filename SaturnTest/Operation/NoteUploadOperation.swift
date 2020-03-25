//
//  NoteUploadOperation.swift
//  SaturnTest
//
//  Created by Bryan Gula on 3/25/20.
//  Copyright © 2020 Bryan Gula. All rights reserved.
//

import Foundation
import SDWebImage

class NoteUploadOperation: AsyncOperation {
    
    var note: Note
    var manager: NotesManager
    
    public init(note: Note, manager: NotesManager) {
        self.note = note
        self.manager = manager
    }
    
    override func main() {
        
        Threading.realmQueue.async {
            guard let image = SDImageCache.shared.imageFromCache(forKey: self.note.localId) else {
                print("there is no local image saved for this note")
                return
            }

            self.manager.addRemote(note: self.note, image: image) {
                self.finish()
            }
        }
    }
}
