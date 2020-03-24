//
//  NotesViewController.swift
//  SaturnTest
//
//  Created by Bryan Gula on 3/22/20.
//  Copyright © 2020 Bryan Gula. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

public protocol NoteCreationDelegate: NSObject {
    func save(note: Note, image: UIImage)
}

public final class NotesViewController: BaseController {
    
    private var tableView: UITableView
    private var dataSource: NotesDataSource
    private var notesManager: NotesManager
        
    init(manager: NotesManager) {
        notesManager = manager
        dataSource = .init(notes: [Note]())
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(NoteTableViewCell.self, forCellReuseIdentifier: NoteTableViewCell.reuseIdentifier)
        tableView.dataSource = dataSource
        tableView.rowHeight = 90
        super.init()
        tableView.delegate = self
        notesManager.delegate = self
        setupConstraints()
        addActions()
    }
    
    private func setupConstraints() {
        view.addAndConstrainToParent(tableView)
    }
    
    private func addActions() {
        let rightItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(showNoteCreationController(sender:)))
        rightItem.setTitleTextAttributes([.foregroundColor : UIColor.blue], for: .normal)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    // actions
    //
    @objc func showNoteCreationController(sender: UIButton) {
        let noteVC = NoteCreationViewController()
        let nav = BaseNavigationController(rootViewController: noteVC)
        noteVC.delegate = self
        noteVC.modalPresentationStyle = .pageSheet
        noteVC.modalTransitionStyle = .coverVertical
        present(nav, animated: true, completion: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NotesViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // retry upload if needed
        let note = dataSource.note(for: indexPath)
        notesManager.retryUploadingNote(note)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension NotesViewController: NoteCreationDelegate {
    public func save(note: Note, image: UIImage) {
        
        notesManager.save(note: note, image: image)
        
        Threading.main {
            //  while model is updating server side,
            //  adding here
            //
            self.dataSource.add(note)
            self.tableView.reloadData()
        }
        //  update view to show loading
        //  reload and show spinner
    }
}

extension NotesViewController: NotesManagerDelegate {
    
    public func didUpload(note: Note) {
        Threading.main {
            self.dataSource.updateNote(note)
            self.tableView.reloadData()
        }
    }
    
    public func didUpdate(notes: [Note]) {
        Threading.main {
            self.dataSource.replaceAll(notes)
            self.tableView.reloadData()
        }
    }
}
