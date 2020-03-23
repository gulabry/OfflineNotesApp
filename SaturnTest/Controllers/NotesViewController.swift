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
        dataSource = .init(notes: manager.notes)
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(NoteTableViewCell.self, forCellReuseIdentifier: NoteTableViewCell.reuseIdentifier)
        tableView.dataSource = dataSource
        super.init()
        tableView.delegate = self
        
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
        
        let note = dataSource.note(for: indexPath)
        // retry upload if needed
    }
}

extension NotesViewController: NoteCreationDelegate {
    public func save(note: Note, image: UIImage) {
        //  add note locally
        
        notesManager.save(note: note, image: image)
        
        Threading.main {
            self.dataSource.add(note)
            self.tableView.reloadData()
        }
        //  update view to show loading
        //  reload and show spinner
    }
}

extension NotesViewController: NotesManagerDelegate {
    
    public func notesDidUpdate(notes: [Note]) {
        Threading.main {
            self.dataSource.update(notes)
            self.tableView.reloadData()
        }
    }
}
