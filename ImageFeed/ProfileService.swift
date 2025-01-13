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
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
    }
}

struct Profile {
    let username: String?
    let firstName: String?
    let lastName: String?
    var name: String? {
        if let firstName = self.firstName, let last_name = self.lastName {
            return (firstName + " " + last_name)
        }
        else if let firstName = self.firstName {
            return firstName
        }
        else if let lastName = self.lastName {
            return lastName
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
