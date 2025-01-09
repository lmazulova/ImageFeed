
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
        
        guard let token = OAuth2TokenStorage().token else {return}
        ProfileService().fetchProfile(token){
            result in
            switch result {
            case .success(let Profile):
                let name = self.addLabel(text: Profile.name)
                name.font = UIFont.systemFont(ofSize: 23, weight: .bold)
                let tag = self.addLabel(text: Profile.loginName)
                tag.textColor = .ypGrey
                let description = self.addLabel(text: Profile.bio)
                let profile = self.addImageView(imageName: "profilePhoto")
                let exitButton = self.addButton(imageName: "Exit")
                
                NSLayoutConstraint.activate([
                    profile.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 32),
                    profile.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                    profile.heightAnchor.constraint(equalToConstant: 70),
                    profile.widthAnchor.constraint(equalToConstant: 70),
                    name.topAnchor.constraint(equalTo: profile.bottomAnchor, constant: 8),
                    tag.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 8),
                    description.topAnchor.constraint(equalTo: tag.bottomAnchor, constant: 8),
                    exitButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
                    exitButton.centerYAnchor.constraint(equalTo: profile.centerYAnchor),
                    exitButton.heightAnchor.constraint(equalToConstant: 22),
                    exitButton.widthAnchor.constraint(equalToConstant: 20)
                ])
            case .failure(let error):
                print(error)
                break
        }
        }
    }
    
    private func updateProfileDetails(profile: Profile) {
        
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
