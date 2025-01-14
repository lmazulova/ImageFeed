import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private (set) var avatarURL: String?
    
    private init() {}
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        guard let token = OAuth2TokenStorage.shared.token else { return }
        let url = URL(string: "https://api.unsplash.com/users/\(username)")!
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
}

// MARK: - Codable structures
struct UserProfile: Codable {
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let medium: String
}
