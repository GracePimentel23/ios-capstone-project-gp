//
//  ViewController.swift
//  ios101-capstone
//
//  Created by Grace P on 8/5/25.
//

import UIKit
import PhotosUI

final class ViewController: UIViewController, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let todayLabel = UILabel()
    private let imageView = UIImageView()
    private let addButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .systemBackground

        // Today label
        todayLabel.textAlignment = .center
        todayLabel.font = .preferredFont(forTextStyle: .title2)
        todayLabel.text = DateFormatter.localizedString(from: Date(), dateStyle: .full, timeStyle: .none)

        // Image preview
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .secondarySystemBackground
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1).isActive = true

        // Add button
        addButton.setTitle("Add Today’s Photo", for: .normal)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)

        // Layout
        let stack = UIStackView(arrangedSubviews: [todayLabel, imageView, addButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        // Load today’s saved image if it exists
        if let img = Store.loadTodayImage() {
            imageView.image = img
            addButton.setTitle("Replace Today’s Photo", for: .normal)
        }
    }

    // MARK: - Add / Upload
    @objc private func addTapped() {
        let ac = UIAlertController(title: "Add Photo", message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            ac.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in self.presentCamera() })
        }
        ac.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in self.presentLibrary() })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

    private func presentLibrary() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func presentCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: - Delegates
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        guard let item = results.first?.itemProvider, item.canLoadObject(ofClass: UIImage.self) else { return }
        item.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self, let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self.imageView.image = image
                do {
                    try Store.saveTodayImage(image)
                    self.addButton.setTitle("Replace Today’s Photo", for: .normal)
                } catch {
                    print("Save failed:", error)
                }
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer { picker.dismiss(animated: true) }
        guard let image = info[.originalImage] as? UIImage else { return }
        imageView.image = image
        do {
            try Store.saveTodayImage(image)
            addButton.setTitle("Replace Today’s Photo", for: .normal)
        } catch {
            print("Save failed:", error)
        }
    }
}

