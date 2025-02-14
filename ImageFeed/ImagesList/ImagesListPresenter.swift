import UIKit


public protocol ImagesListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func shouldUpdateTable(newPhotos: [Photo])
    var view: ImagesListControllerProtocol? { get set }
    func shouldDownloadImages(indexPath: IndexPath)
    func changeLike(photo: Photo, completion: @escaping (Result<[Photo], Error>) -> Void)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    private var ImageListServiceObserver: NSObjectProtocol?
    weak var view: ImagesListControllerProtocol?
    var imageListService: ImagesListServiceProtocol?
    
    init(imageListService: ImagesListServiceProtocol? = ImagesListService.shared) {
        self.imageListService = imageListService
    }
    
    func viewDidLoad() {
        imageListService?.fetchPhotosNextPage()
        ImageListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let newPhotos = notification.userInfo?["photos"] as? [Photo]
            else { return }
            self.shouldUpdateTable(newPhotos: newPhotos)
        }
    }
    deinit {
        if let observer = ImageListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func shouldUpdateTable(newPhotos: [Photo]) {
        if let lastPhotos = view?.photos,
           lastPhotos.count != newPhotos.count {
            DispatchQueue.main.async{
                self.view?.updateTableViewAnimated(newPhotos: newPhotos, from: lastPhotos.count, to: newPhotos.count)
            }
        }
        else {
            print("[ImageListPresenter.shouldUpdateTable] - не удалось получить новые фото")
            return
        }
    }
    
    func shouldDownloadImages(indexPath: IndexPath) {
        if indexPath.row + 1 == view?.photos.count {
            imageListService?.fetchPhotosNextPage()
        }
    }
    
    func changeLike(photo: Photo, completion: @escaping (Result<[Photo], Error>) -> Void) {
        imageListService?.changeLike(photoId: photo.id, isLiked: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success():
                if let photos = imageListService?.photos {
                    completion(.success(photos))
                }
                else {
                    let error = NSError()
                    completion(.failure(error))
                }
            case .failure(let error):
                print("[ImagesListPresenter.changeLike] - ошибка при изменении лайка: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
