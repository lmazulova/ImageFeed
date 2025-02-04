import UIKit

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var baseUrl = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("[OAuth2Service.makeOAuthTokenRequest] - Invalid host name")
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
            print("[OAuth2Service.makeOAuthTokenRequest] - Failed to construct URL. Wrong query items.")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            print("[fetchOAuthToken]: AuthServiceError.invalidRequest")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        guard let URLRequest = makeOAuthTokenRequest(code: code)
        else {
            print("[fetchOAuthToken]: AuthServiceError.invalidRequest")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        let task = URLSession.shared.objectTask(for: URLRequest){ [weak self]
            (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let responseBody):
                OAuth2TokenStorage.shared.token = responseBody.accessToken
                completion(.success("success"))
            case .failure(let error):
                print("[AuthServiceError.fetchOAuthToken] - \(error)")
                completion(.failure(error))
            }
            
            DispatchQueue.main.async {
                self?.task = nil
                self?.lastCode = nil
            }
        }
        self.task = task
        task.resume()
    }
}
