//
//  NotesDataSource.swift
//  SaturnTest
//
//  Created by Bryan Gula on 3/22/20.
//  Copyright © 2020 Bryan Gula. All rights reserved.
//

import Foundation
import UIKit

public class NotesDataSource: NSObject, UITableViewDataSource {
    
    private var notes: [Note]
    
    init(notes: [Note]) {
        self.notes = notes
    }
    
    public func update(_ notes: [Note]) {
        self.notes = notes
    }
    
    public func add(_ note: Note) {
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
    
    public static func mockData() -> [Note] {
        
        let note1 = Note()
        note1.id = UUID().uuidString
        note1.body = "Test note 1"
        
        let note2 = Note()
        note2.id = UUID().uuidString
        note2.body = "Test note 2"
        return [note1, note2]
    }
}
