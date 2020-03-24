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
        return notes[indexPath.row]
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.reuseIdentifier, for: indexPath) as? NoteTableViewCell else { fatalError("table view has incorrect cell type") }
        
        cell.setup(with: notes[indexPath.row])
        
        return cell
    }
}
