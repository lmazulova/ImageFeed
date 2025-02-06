import UIKit

final class ImagesListService {
    
    static let shared = ImagesListService()
    private init() {}
    
    // MARK: - Private Properties
    private (set) var photos: [Photo] = []
    private var task: URLSessionTask?
    private var lastLoadedPage: Int?
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // MARK: - Public methods
    func changeLike(photoId: String, isLiked: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        var httpMethod = "POST"
        if isLiked {
            httpMethod = "DELETE"
        }
        guard let url = URL(string: "\(Constants.defaultBaseURL)/photos/\(photoId)/like"),
              let token = OAuth2TokenStorage.shared.token
        else { return }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = httpMethod
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { completion(.failure(error)) }
            else {
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(where: {$0.id == photoId}) {
                        let photo = self.photos[index]
                        
                        let updatePhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )
                        self.photos[index] = updatePhoto
                    }
                    completion(.success(()))
                }
            }
        }
        task.resume()
    }
    
    func fetchPhotosNextPage() {
        guard task == nil,
              var urlComponents =  URLComponents(string: "\(Constants.defaultBaseURL)/photos"),
              let token = OAuth2TokenStorage.shared.token
        else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        guard let url = urlComponents.url else { return }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) { [weak self]
            (result: Result<[PhotoResult], Error>) in
            switch result {
            case .success(let photoResultArray):
                let dateFormatter = ISO8601DateFormatter()
                let newPhotos = photoResultArray.map { photo in
                    Photo (
                        id: photo.id,
                        size: CGSize(width: photo.width, height: photo.height),
                        createdAt: dateFormatter.date(from: photo.createdAt),
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.photosUrl.thumbImageURL,
                        largeImageURL: photo.photosUrl.largeImageURL,
                        isLiked: photo.isLiked
                    )
                }
                DispatchQueue.main.async {
                    self?.lastLoadedPage = nextPage
                    self?.photos.append(contentsOf: newPhotos)
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                    self?.task = nil
                }
            case .failure(let error):
                print("[ImagesListService.fetchPhotosNextPage] - не удалось загрузить новые фото: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.task = nil
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Logout method
    func cleanPhotosAndReload() {
        photos.removeAll()
        lastLoadedPage = nil
    }
}
