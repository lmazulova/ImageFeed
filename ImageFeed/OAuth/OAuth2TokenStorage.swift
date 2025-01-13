import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private var tokenKey = "OAuth2TokenKey"
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                let isSuccess = KeychainWrapper.standard.set(newValue, forKey: tokenKey)
                guard isSuccess else {
                    print("[OAuth2TokenStorage]: Ошибка сохранения токена")
                    return
                }
            }
        }
    }
}
