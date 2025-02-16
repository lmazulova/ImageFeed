import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
    func ImageLoaded(_ cell: ImagesListCell)
}

public protocol ImagesListControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    var photos: [Photo] { get }
    func updateTableViewAnimated(newPhotos: [Photo], from: Int, to: Int)
}
final class ImagesListViewController: UIViewController & ImagesListControllerProtocol {
    
    // MARK: - Private Properties
    private(set) var photos: [Photo] = []
    var presenter: ImagesListPresenterProtocol?
    
    // MARK: - Table View
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        return tableView
    }()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupTableView()
        presenter?.viewDidLoad()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
    }
    
    // MARK: - Public Methods
    func updateTableViewAnimated(newPhotos: [Photo], from: Int, to: Int) {
        setPhotos(newPhotos: newPhotos)
        tableView.performBatchUpdates{
            let indexPaths = (from..<to).map { i in
                IndexPath(row: i, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
    
    private func setPhotos(newPhotos: [Photo]) {
        photos = newPhotos
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
        imageListCell.configCell(with: url, photo: photos[indexPath.row])
        return imageListCell
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        presenter?.shouldDownloadImages(indexPath: indexPath)
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleImageController = SingleImageViewController()
        singleImageController.imageUrl = URL(string: photos[indexPath.row].largeImageURL)
        singleImageController.modalPresentationStyle = .fullScreen
        present(singleImageController, animated: true)
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
        presenter?.changeLike(photo: photo){ [weak self] (result: Result<Void, Error>) in
            guard let self = self else { return }
            switch result {
            case .success():
                self.photos[indexPath.row].isLiked.toggle()
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
            case .failure(let error):
                print("[ImagesListViewController.imageListCellDidTapLike] - ошибка при изменении лайка \(error.localizedDescription)")
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    func ImageLoaded(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
