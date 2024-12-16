//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by user on 06.12.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - views
    func addLabel(text: String?) -> UILabel{
        let label = UILabel()
        label.text = text
        label.textColor = .ypWhite
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        return label
    }
    
    func addImageView(image: UIImage) -> UIImageView {
        let imgView = UIImageView(image: image)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imgView)
        imgView.contentMode = .scaleAspectFit
        return imgView
    }
    
    func addButton(image: UIImage) -> UIButton {
        let button = UIButton.systemButton(with: image, target: self, action: #selector(Self.didTapButton))
        button.tintColor = .ypRed
        button.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        return button
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        let name = addLabel(text: "Екатерина Новикова")
        name.font = UIFont.systemFont(ofSize: 23)
        let tag = addLabel(text: "@ekaterina_nov")
        tag.textColor = .ypGrey
        let description = addLabel(text: "Hello, world!")
        let profile = addImageView(image: UIImage(named: "profilePhoto")!)
        let exitButton = addButton(image: UIImage(named: "Exit")!)
        
        NSLayoutConstraint.activate([
            profile.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profile.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profile.heightAnchor.constraint(equalToConstant: 70),
            profile.widthAnchor.constraint(equalToConstant: 70),
            name.topAnchor.constraint(equalTo: profile.bottomAnchor, constant: 8),
            tag.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 8),
            description.topAnchor.constraint(equalTo: tag.bottomAnchor, constant: 8),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            exitButton.centerYAnchor.constraint(equalTo: profile.centerYAnchor),
            exitButton.heightAnchor.constraint(equalToConstant: 22),
            exitButton.widthAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    @objc
    private func didTapButton() {
        for view in view.subviews {
            if view is UILabel {
                view.removeFromSuperview()
            }
        }
    }
    
}
