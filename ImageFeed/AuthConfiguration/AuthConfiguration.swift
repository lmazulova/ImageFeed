import Foundation

enum Constants {
    static let accessKey = "Xv5HvF9p0Y-kfgKfhqncEAX1_5aAXu0qcYCyBRf8Gzs"
    static let secretKey = "UEyMOLEg3KX6W_5DG92DO5bMn1P_BfvBjTWQzF1sGS4"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, authURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    static var standart: AuthConfiguration {
        return AuthConfiguration(
            accessKey: Constants.accessKey ,
            secretKey: Constants.secretKey ,
            redirectURI: Constants.redirectURI ,
            accessScope: Constants.accessKey ,
            defaultBaseURL: Constants.defaultBaseURL ,
            authURLString: Constants.unsplashAuthorizeURLString
        )
    }
}
