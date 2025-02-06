import UIKit
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    private init() { }
    
    func logout() {
        cleanCookies()
        OAuth2TokenStorage.shared.logout()
        ProfileService.shared.removeProfileInfo()
        ProfileImageService.shared.removeAvatar()
        ImagesListService.shared.cleanPhotosAndReload()
        switchToSplashScreen()
    }
    
    // MARK: - Private methods
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach{ record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func switchToSplashScreen() {
        guard let window = UIApplication.shared.windows.first else {
                    assertionFailure("Invalid window configuration")
                    return
                }
                let splashVC = SplashViewController()
                window.rootViewController = splashVC
    }
}
