//
//  NoteCreationViewController.swift
//  SaturnTest
//
//  Created by Bryan Gula on 3/22/20.
//  Copyright © 2020 Bryan Gula. All rights reserved.
//

import UIKit

public class NoteCreationViewController: BaseController {
    
    var textView: UITextView
    var imageView: UIImageView
    var selectImageButton: UIButton
    
    var image: UIImage?
    var noteBody: String?
    
    weak var delegate: NoteCreationDelegate?
    
    public override init() {
        textView = UITextView(frame: .zero)
        imageView = UIImageView(frame: .zero)
        selectImageButton = UIButton(frame: .zero)
        super.init()
        setupConstraints()
        setupActions()
    }
    
    private func setupActions() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismiss(sender:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(addNoteAndDismiss(sender:)))
    }
    
    private func setupConstraints() {
        view.setup(textView)
        textView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).activate()
        textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).activate()
        textView.heightAnchor.constraint(equalToConstant: 100).activate()
        textView.centerX(in: self.view)
        
        view.setup(imageView)
        imageView.constrainTo(size: 80)
        imageView.centerX(in: self.view)
        imageView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20).activate()
        imageView.backgroundColor = .gray
        
        view.setup(selectImageButton)
        selectImageButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).activate()
        selectImageButton.centerX(in: self.view)
        selectImageButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).activate()
        selectImageButton.heightAnchor.constraint(equalToConstant: 50).activate()
        selectImageButton.setTitle("Choose Image", for: .normal)
        selectImageButton.backgroundColor = .darkGray
        selectImageButton.addTarget(self, action: #selector(showImagePicker(sender:)), for: .touchUpInside)
    }
    
    @objc func showImagePicker(sender: UIButton) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = false
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        textView.becomeFirstResponder()
    }
    
    //  Actions
    @objc func addNoteAndDismiss(sender: UIButton) {
        
        noteBody = textView.text
        
        guard let image = image,
            let body = noteBody,
            body.count > 0 else {
            showErrorAlert()
            return
        }
        
        let note = Note()
        note.body = body
        note.localId = UUID().uuidString
        note.imageLocalId = note.localId
        //note.isAdding = true
        
        delegate?.save(note: note, image: image)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func dismiss(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showErrorAlert() {
        
        let alertVC = UIAlertController(title: "Complete Note Before Adding",
                                        message: "Ensure a photo and message is included in your note",
                                        preferredStyle: .alert)
        
        let done = UIAlertAction(title: "Done", style: .default) { action in
            alertVC.dismiss(animated: true, completion: nil)
        }
        
        alertVC.addAction(done)
        present(alertVC, animated: true, completion: nil)
    }
}

extension NoteCreationViewController: UIImagePickerControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return picker.dismiss(animated: true, completion: nil)
        }
        
        self.imageView.image = image
        self.image = image
        picker.dismiss(animated: true, completion: nil)
    }
}
