
import UIKit

final class ProfileViewController: UIViewController {
    
    private var profileImageServiceObserver: NSObjectProtocol?
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
    
    func addImageView(imageName: String) -> UIImageView {
        guard let image = UIImage(named: imageName) else {
            fatalError("Ошибка: изображение '\(imageName)' не найдено")
        }
        let imgView = UIImageView(image: image)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imgView)
        imgView.contentMode = .scaleAspectFit
        return imgView
    }
    
    func addButton(imageName: String) -> UIButton {
        guard let image = UIImage(named: imageName) else {
            fatalError("Ошибка: изображение '\(imageName)' не найдено")
        }
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
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else {return}
                self.updateAvatar()
            }
        updateAvatar()
        guard let profile = ProfileService.shared.profile else {return}
        self.updateProfileDetails(profile: profile)
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
    }
    
    private func updateProfileDetails(profile: Profile) {
        let name = self.addLabel(text: profile.name)
        name.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        let tag = self.addLabel(text: profile.loginName)
        tag.textColor = .ypGrey
        let description = self.addLabel(text: profile.bio)
        let profile = self.addImageView(imageName: "profilePhoto")
        let exitButton = self.addButton(imageName: "Exit")
        
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
