//
//  NotesViewController.swift
//  SaturnTest
//
//  Created by Bryan Gula on 3/22/20.
//  Copyright © 2020 Bryan Gula. All rights reserved.
//

import Foundation
import UIKit

public protocol NoteCreationDelegate: NSObject {
    func save(note: Note, imageData: Data)
}

public final class NotesViewController: BaseController {
    
    private var tableView: UITableView
    private var dataSource: NotesDataSource = .init(notes: NotesDataSource.mockData())
    private var notesManager: NotesManager
        
    init(manager: NotesManager) {
        notesManager = manager
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
    public func save(note: Note, imageData: Data) {
        //  add note locally
        //  update view to show loading
        notesManager.save(note: note, imageData: imageData)
    }
}
