
import UIKit
import ProgressHUD
import SwiftKeychainWrapper

final class SplashViewController: UIViewController {
    // MARK: - Private Properties
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let profileService = ProfileService.shared
    
    // MARK: - Private Methods
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    // MARK: - views
    private func configureImageView(image: UIImage?) {
        guard let image = image else { return }
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        view.backgroundColor = .ypBlack
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0),
            imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 0)
        ])
    }
    
    // MARK: - View controller lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureImageView(image: UIImage(named: "LaunchImage"))
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let _ = KeychainWrapper.standard.removeObject(forKey: "OAuth2TokenKey")
        if let token = OAuth2TokenStorage.shared.token {
            self.fetchProfile(token)
        } else {
            let AuthViewController = AuthViewController()
            AuthViewController.delegate = self
            let navigationController = UINavigationController(rootViewController: AuthViewController)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true, completion: nil)
        }
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController, code: String) {
        UIBlockingProgressHUD.show()
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            print(self)
            switch result {
            case .success:
                self.switchToTabBarController()
                guard let username = profileService.profile?.username else { return }
                ProfileImageService.shared.fetchProfileImageURL(username: username) { result in
                    switch result {
                    case .success(let avatarURL):
                        print(avatarURL)
                    case .failure(let error):
                        print(error)
                        break
                    }
                }
            case .failure(let error):
                print(error)
                break
            }
        }
    }
}

// MARK: - Extensions
extension SplashViewController {
    private func fetchOAuthToken(_ code: String) {
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success:
                guard let token = OAuth2TokenStorage.shared.token else { return }
                self.fetchProfile(token)
            case .failure:
                let alert = UIAlertController(
                    title: "Что-то пошло не так(",
                    message: "Не удалось войти в систему",
                    preferredStyle: .alert
                )
                let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                break
            }
        }
    }
}
