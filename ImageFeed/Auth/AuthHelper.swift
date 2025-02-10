import UIKit

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    let configuration: AuthConfiguration
    
    init(configuration: AuthConfiguration) {
        self.configuration = configuration
    }
    
    func authURL() -> URL? {
        guard var urlComponents = URLComponents(string: webViewConstants.unsplashAuthorizeURLString) else {
            print("[AuthHelper.authURL] - Invalid authorization URL")
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        return urlComponents.url
    }
    
    func authRequest() -> URLRequest? {
        guard let url = authURL() else {
            print("[AuthHelper.authRequest] - Failed to construct URL. Wrong query items.")
            return nil
        }
        return URLRequest(url: url)
    }
    
    func code(from url: URL) -> String? {
        if
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code"}) {
                return codeItem.value
        }
        return nil
    }
}
