import UIKit

public protocol ProfileServiceProtocol: AnyObject {
    var profile: Profile? { get }
}

final class ProfileService: ProfileServiceProtocol {
    static let shared = ProfileService()
    private init() {}
    
    // MARK: - Private Properties
    private let urlSession = URLSession.shared
    private(set) var profile: Profile?
    private var task: URLSessionTask?
    
    // MARK: - Profile data fetching
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        let url = URL(string: "https://api.unsplash.com/me")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.objectTask(for: request){ [weak self]
            (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let responseBody):
                let profile = Profile(
                    username: responseBody.username,
                    firstName: responseBody.firstName,
                    lastName: responseBody.lastName,
                    bio: responseBody.bio
                )
                self?.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("[ProfileService.fetchProfile] - \(error)")
                completion(.failure(error))
            }
            
            DispatchQueue.main.async {
                self?.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Logout method
    func removeProfileInfo() {
        profile = nil
    }
}
