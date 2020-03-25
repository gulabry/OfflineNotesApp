//
//  NotesDataSource.swift
//  SaturnTest
//
//  Created by Bryan Gula on 3/22/20.
//  Copyright © 2020 Bryan Gula. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import SDWebImage

public class NotesDataSource: NSObject, UITableViewDataSource {
    
    private var notes: [Note]
    
    init(notes: [Note]) {
        self.notes = notes
    }
    
    public func updateNote(_ note: Note) {
        var updatedNotes = self.notes
        if let row = self.notes.firstIndex(where: { $0.localId == note.localId }) {
            updatedNotes[row] = note
        }
        self.notes = updatedNotes
    }
    
    public func replaceAll(_ notes: [Note]) {
        self.notes = notes
    }
    
    public func add(_ note: Note) {
    
        //  update spinner until added
        let realm = try! Realm()
        try! realm.write {
            note.isAdding = true
        }
        self.notes.insert(note, at: 0)
    }
    
    public func note(for indexPath: IndexPath) -> Note {
        return notes[indexPath.section]
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return notes.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.reuseIdentifier, for: indexPath) as? NoteTableViewCell else { fatalError("table view has incorrect cell type") }
        
        let note = notes[indexPath.section]
        cell.setup(with: note)
                
        let localId = note.localId
        let imageId = note.imageId
        let imageURLString = note.imageURLString
        
        Threading.inBackground {
            if let savedImage = SDImageCache.shared.imageFromCache(forKey: imageId) ?? SDImageCache.shared.imageFromCache(forKey: localId) {
                Threading.main {
                    if let visableCell = tableView.cellForRow(at: indexPath) as? NoteTableViewCell {
                        visableCell.noteImageView.image = savedImage
                    }
                }
            } else if let imageURL = URL(string: imageURLString) {
                
                SDWebImageDownloader.shared.downloadImage(with: imageURL) { (image, _, error, _) in
                    Threading.main {
                        if let visableCell = tableView.cellForRow(at: indexPath) as? NoteTableViewCell {
                            visableCell.noteImageView.image = image
                        }
                    }
                    guard let image = image else { return }
                    Threading.inBackground {
                        let scaledDownImage = UIImage(data: image.jpegData(compressionQuality: 0.1)!)
                        SDImageCache.shared.store(scaledDownImage, forKey: imageId, toDisk: true, completion: nil)
                     }
                }
            }
        }
        
        return cell
    }
}
