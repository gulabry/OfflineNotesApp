//
//  NoteTableViewCell.swift
//  SaturnTest
//
//  Created by Bryan Gula on 3/22/20.
//  Copyright © 2020 Bryan Gula. All rights reserved.
//

import UIKit
import SDWebImage
import RealmSwift

class NoteTableViewCell: UITableViewCell {
    
    var noteImageView: UIImageView
    var titleLabel: UILabel
    var statusView: UIView
    var statusCircleView: UIView
    var spinnerView: UIActivityIndicatorView

    static let reuseIdentifier = "NoteTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        noteImageView = UIImageView()
        titleLabel = UILabel()
        statusView = UIView()
        statusCircleView = UIView()
        spinnerView = UIActivityIndicatorView(style: .medium)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }
    
    public func setup(with note: Note) {
        
        self.titleLabel.text = note.body
        
        let imageID = note.imageId
        self.noteImageView.image = nil

        if note.isAdding {
            self.spinnerView.isHidden = false
            self.spinnerView.startAnimating()
            self.statusCircleView.isHidden = true
        } else {
            self.spinnerView.stopAnimating()
            self.spinnerView.isHidden = true
            self.statusCircleView.isHidden = false
        }
        
        self.statusCircleView.backgroundColor = note.id == 0 ? .red : .green
    }
    
    func setupConstraints() {
        noteImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(noteImageView)
        noteImageView.constrainTo(top: 0, bottom: 0, of: self)
        noteImageView.leadingAnchor.constraint(equalTo: leadingAnchor).activate()
        noteImageView.widthAnchor.constraint(equalTo: noteImageView.heightAnchor).activate()
        noteImageView.backgroundColor = .black
        noteImageView.clipsToBounds = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        titleLabel.centerIn(view: self)
        titleLabel.leadingAnchor.constraint(equalTo: noteImageView.trailingAnchor, constant: 20).activate()
        
        statusView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(statusView)
        statusView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).activate()
        statusView.constrainTo(top: 0, bottom: 0, of: self)
        statusView.widthAnchor.constraint(equalTo: statusView.heightAnchor).activate()
        statusView.backgroundColor = .lightGray
        
        statusCircleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(statusCircleView)
        statusCircleView.centerIn(view: statusView)
        statusCircleView.constrainTo(size: 20)
        statusCircleView.layer.cornerRadius = 10
        
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(spinnerView)
        spinnerView.centerIn(view: statusView)
        spinnerView.tintColor = .white
    }
    
    override func prepareForReuse() {
        noteImageView.image = nil
        titleLabel.text = ""
        spinnerView.stopAnimating()
        spinnerView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
