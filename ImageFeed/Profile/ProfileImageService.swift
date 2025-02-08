import UIKit

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() {}
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    // MARK: - Private Properties
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private (set) var avatarURL: String?
    
    // MARK: - Fetching profile photo
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        guard let token = OAuth2TokenStorage.shared.token,
              let url = URL(string: "\(Constants.defaultBaseURL)/users/\(username)")
        else { return }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.objectTask(for: request){ [weak self]
            (result: Result<UserProfile, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let responseBody):
                let avatarURL = responseBody.profileImage.medium
                self.avatarURL = avatarURL
                completion(.success(avatarURL))
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL])
            case .failure(let error):
                print("[fetchProfileImageURL] - \(error)")
                completion(.failure(error))
            }
            DispatchQueue.main.async {
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Logout method
    func removeAvatar() {
        avatarURL = nil
    }
}




