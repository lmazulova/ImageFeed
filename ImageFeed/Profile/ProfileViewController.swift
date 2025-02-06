
import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private var profileImageServiceObserver: NSObjectProtocol?
    // MARK: - views
    private func addLabel(text: String?) -> UILabel{
        let label = UILabel()
        label.text = text
        label.textColor = .ypWhite
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        return label
    }
    
    private func addButton(imageName: String) -> UIButton {
        guard let image = UIImage(named: imageName) else {
            assertionFailure("[ProfileViewController.addButton] - Error: изображение '\(imageName)' не найдено")
            return UIButton(type: .system)
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
                guard let self = self else { return }
                self.updateAvatar()
            }
        self.updateAvatar()
        guard let profile = ProfileService.shared.profile else { return }
        self.updateProfileDetails(profile: profile)
    }
    
    // MARK: - private Methods
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70)
        ])
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url,
                              placeholder: UIImage(named: "userAvatar"))
    }
    
    private func updateProfileDetails(profile: Profile) {
        let name = self.addLabel(text: profile.name)
        name.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        let tag = self.addLabel(text: profile.loginName)
        tag.textColor = .ypGrey
        let description = self.addLabel(text: profile.bio)
        let exitButton = self.addButton(imageName: "Exit")
        
        NSLayoutConstraint.activate([
            name.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 110),
            tag.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 8),
            description.topAnchor.constraint(equalTo: tag.bottomAnchor, constant: 8),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            exitButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 55),
            exitButton.heightAnchor.constraint(equalToConstant: 22),
            exitButton.widthAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    @objc
    private func didTapButton() {
        ProfileLogoutService.shared.logout()
    }
}
