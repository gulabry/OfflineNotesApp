//
//  NoteTableViewCell.swift
//  SaturnTest
//
//  Created by Bryan Gula on 3/22/20.
//  Copyright © 2020 Bryan Gula. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {
    
    var noteImageView: UIImageView
    var titleLabel: UILabel
    var statusView: UIView
    var statusCircleView: UIView

    static let reuseIdentifier = "NoteTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        noteImageView = UIImageView()
        titleLabel = UILabel()
        statusView = UIView()
        statusCircleView = UIView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }
    
    public func setup(with note: Note) {
        titleLabel.text = note.body
    }
    
    func setupConstraints() {
        noteImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(noteImageView)
        noteImageView.constrainTo(top: 0, bottom: 0, of: self)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        titleLabel.centerIn(view: self)
        titleLabel.leadingAnchor.constraint(equalTo: noteImageView.trailingAnchor, constant: 20).activate()
        
        statusView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(statusView)
        statusView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).activate()
        statusView.constrainTo(top: 0, bottom: 0, of: self)
        statusView.widthAnchor.constraint(equalTo: statusView.heightAnchor).activate()
        
        statusCircleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(statusCircleView)
        statusCircleView.centerIn(view: statusView)
        statusCircleView.constrainTo(size: 20)
    }
    
    override func prepareForReuse() {
        noteImageView.image = nil
        titleLabel.text = ""
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
