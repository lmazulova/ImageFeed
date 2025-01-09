import UIKit
final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    private let urlSession = URLSession.shared
    private(set) var profile: Profile?
    private var task: URLSessionTask?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        let url = URL(string: "https://api.unsplash.com/me")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.data(for: request){ [weak self]
            result in
            switch result {
            case .success(let data):
                do {
                    let ProfileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
                    let profile = Profile(
                        username: ProfileResult.username,
                        first_name: ProfileResult.first_name,
                        last_name: ProfileResult.last_name,
                        bio: ProfileResult.bio
                    )
                    self?.profile = profile
                    completion(.success(profile))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
            
            DispatchQueue.main.async {
                        self?.task = nil
            }
        }
        self.task = task
        task.resume()
    }
}

struct ProfileResult: Codable {
    let username: String?
    let first_name: String?
    let last_name: String?
    let bio: String?
}

struct Profile {
    let username: String?
    let first_name: String?
    let last_name: String?
    var name: String? {
        if let first_name = self.first_name, let last_name = self.last_name {
           return (first_name + " " + last_name)
        }
        else if let first_name = self.first_name {
            return first_name
        }
        else if let last_name = self.last_name {
            return last_name
        }
        else {
            return nil
        }
    }
    var loginName: String? {
        if let username = self.username {
            return "@" + username
        }
        else {
            return nil
        }
    }
    let bio: String?
}
