import UIKit

public protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? {get set}
    func viewDidLoad()
    func handleLogout()
    func updateAvatar()
    func updateProfileDetails(profile: Profile)
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private var profileImageService: ProfileImageServiceProtocol?
    private var profileService: ProfileServiceProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?
    
    init(profileImageService: ProfileImageServiceProtocol? = ProfileImageService.shared,
         profileService: ProfileServiceProtocol? = ProfileService.shared) {
        self.profileImageService = profileImageService
        self.profileService = profileService
    }
    
    func viewDidLoad() {
        updateAvatar()
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                guard let view = self?.view,
                      let userInfo = notification.userInfo,
                      let urlString = userInfo["URL"] as? String,
                      let url = URL(string: urlString) else { return }
                view.updateAvatarImage(with: url)
            }
        
        profileService = ProfileService.shared
        guard let profile = profileService?.profile else {
            print("[ProfilePresenter] - profile is not available")
            return
        }
        updateProfileDetails(profile: profile)
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func updateAvatar() {
        guard
            let profileImageURL = profileImageService?.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        view?.updateAvatarImage(with: url)
    }
    
    func updateProfileDetails(profile: Profile) {
        view?.updateProfileDetails(profile: profile)
    }
    
    func handleLogout() {
        view?.showLogoutAlert()
    }
}
