import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
    func ImageLoaded(_ cell: ImagesListCell)
}

final class ImagesListViewController: UIViewController {
    // MARK: - IB Outlets
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Private Properties
    private var ImageListServiceObserver: NSObjectProtocol?
    private var photos: [Photo] = []
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        ImagesListService.shared.fetchPhotosNextPage()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        ImageListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateTableViewAnimated()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController,
                  let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            viewController.imageUrl = URL(string: photos[indexPath.row].largeImageURL)
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Public Methods
    func updateTableViewAnimated() {
        let photosBefore = photos.count
        let photosAfter = ImagesListService.shared.photos.count
        guard photosBefore != photosAfter else { 
            print("[ImagesListViewController.updateTableViewAnimated] - не удалось получить новые фото")
            return }
        photos = ImagesListService.shared.photos
        tableView.performBatchUpdates{
            let indexPaths = (photosBefore..<photosAfter).map { i in
                IndexPath(row: i, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
}


// MARK: - Extension UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell,
              let url = URL(string: photos[indexPath.row].thumbImageURL) else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        imageListCell.selectionStyle = .none
        imageListCell.configCell(with: url, indexPath: indexPath)

        return imageListCell
    }
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row + 1 == photos.count {
            ImagesListService.shared.fetchPhotosNextPage()
        }
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if photos[indexPath.row].size.height != 0 {
            let imageSize = photos[indexPath.row].size
            let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
            let ratio = (tableView.frame.width - imageInsets.left - imageInsets.right) / imageSize.width
            let height = ratio * imageSize.height + imageInsets.top + imageInsets.bottom
            return height
        }
        else {
            guard let imageSize = UIImage(named: "stub")?.size else { return 0 }
            let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
            let ratio = (tableView.frame.width - imageInsets.left - imageInsets.right) / imageSize.width
            let height = ratio * imageSize.height + imageInsets.top + imageInsets.bottom
            return height
        }
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        ImagesListService.shared.changeLike(photoId: photo.id, isLiked: photo.isLiked){ [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(()):
                self.photos = ImagesListService.shared.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
            case .failure(let error):
                print("[ImagesListViewController.imageListCellDidTapLike] - ошибка при изменении лайка: \(error.localizedDescription)")
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    func ImageLoaded(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
