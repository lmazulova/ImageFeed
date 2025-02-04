import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Decodable {
    let id: String
    let height: Int
    let width: Int
    let createdAt: Date?
    let welcomeDescription: String?
    let photosUrl: UrlsResult
    let isLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case height = "height"
        case width = "width"
        case createdAt = "created_at"
        case welcomeDescription = "description"
        case photosUrl = "urls"
        case isLiked = "liked_by_user"
    }
}

struct UrlsResult: Decodable {
    let thumbImageURL: String
    let largeImageURL: String

    enum CodingKeys: String, CodingKey {
        case thumbImageURL = "thumb"
        case largeImageURL = "full"
    }
}

final class ImagesListService {
    static let shared = ImagesListService()
    private init() {}
    private (set) var photos: [Photo] = []
    private var task: URLSessionTask?
    private var lastLoadedPage: Int?
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func fetchPhotosNextPage() {
        guard task == nil,
              let url = URL(string: "\(Constants.defaultBaseURL)/photos"),
              let token = OAuth2TokenStorage.shared.token
        else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["Authorization": "Bearer \(token)",
                                    "page": "\(nextPage)",
                                    "per_page": "10"]
        
        let task = URLSession.shared.objectTask(for: request) { [weak self]
            (result: Result<[PhotoResult], Error>) in
            switch result {
            case .success(let photoResultArray):
                let photos = photoResultArray.map { photo in
                    Photo (
                        id: photo.id,
                        size: CGSize(width: photo.width, height: photo.height),
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.photosUrl.thumbImageURL,
                        largeImageURL: photo.photosUrl.largeImageURL,
                        isLiked: photo.isLiked
                    )
                }
                DispatchQueue.main.async {
                    self?.photos.append(contentsOf: photos)
                    self?.lastLoadedPage = nextPage - 1
                }
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self
                )
            case .failure(let error):
                print(error)
            }
            DispatchQueue.main.async {
                self?.task = nil
            }
        }
        self.task = task
        task.resume()
    }
}
