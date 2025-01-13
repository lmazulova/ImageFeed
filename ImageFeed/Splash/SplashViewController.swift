
import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    // MARK: - Private Properties
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let storage = OAuth2TokenStorage()
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
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let launchImage = UIImage(named: "LaunchImage")
        let logoView = UIImageView(image: launchImage)
        logoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoView)
        NSLayoutConstraint.activate([
            logoView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0),
            logoView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 0)
        ])
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = storage.token {
            print(token)
            self.fetchProfile(token)
        } else {
            let viewController = AuthViewController()
            viewController.delegate = self
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: true, completion: nil)
//            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController, code: String) {
        UIBlockingProgressHUD.show()
        print(#line)
        vc.dismiss(animated: true) { [weak self] in
            print(#line)
            guard let self = self else {
                print(#line)
                return}
            self.fetchOAuthToken(code)
        }
    }
     
//    нормально ли делать switch внутри switch
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
                ProfileImageService.shared.fetchProfileImageURL(username: username) {
//                        [weak self]
                    result in
//                        guard let self = self else { return }
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
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == showAuthenticationScreenSegueIdentifier {
//            guard
//                let navigationController = segue.destination as? UINavigationController,
//                let viewController = navigationController.viewControllers[0] as? AuthViewController
//            else { fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)") }
//            viewController.delegate = self
//        } else {
//            super.prepare(for: segue, sender: sender)
//        }
//    }
    private func fetchOAuthToken(_ code: String) {
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success:
                guard let token = storage.token else {
                    return
                }
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
