import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListViewController: UIViewController {
    // MARK: - IB Outlets
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Private Properties
    private var ImageListServiceObserver: NSObjectProtocol?
    private var photos: [Photo] = []
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
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
        
        configCell(for: imageListCell, with: url, indexPath: indexPath)
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
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                print("[ImagesListViewController.imageListCellDidTapLike] - ошибка при изменении лайка: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Cell setup
extension ImagesListViewController {
    func applyGradient(to view: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.ypBlackAlpha0.cgColor, UIColor.ypBlackAlpha02.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.masksToBounds = true
        view.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach{ $0.removeFromSuperlayer() }
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func configCell(for cell: ImagesListCell, with url: URL, indexPath: IndexPath) {
        applyGradient(to: cell.gradientView)
        cell.ImageView.kf.indicatorType = .activity
        cell.ImageView.kf.setImage(with: url,
                                   placeholder: UIImage(named: "stub")) { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        if let date = photos[indexPath.row].createdAt {
            cell.dataLabel.text = dateFormatter.string(from: date)
        }
        else {
            cell.dataLabel.text = ""
        }
        cell.setIsLiked(photos[indexPath.row].isLiked)
    }
}
