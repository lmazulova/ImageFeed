import UIKit

enum AuthServiceError: Error {
    
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var baseUrl = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("Invalid host name")
            return nil
        }
        baseUrl.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        guard let url = baseUrl.url else {
            print("Failed to construct URL. Wrong query items.")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        if let URLRequest = makeOAuthTokenRequest(code: code){
            let task = URLSession.shared.data(for: URLRequest){
                result in
                switch result {
                case .success(let data):
                    do {
                        let token = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                        OAuth2TokenStorage().token = token.access_token
                        completion(.success("Success"))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
}
