import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    // MARK: - IB Outlets
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var ImageView: UIImageView!
    @IBOutlet private weak var dataLabel: UILabel!
    @IBOutlet private weak var likeButton: UIButton!
    
    // MARK: - Delegate
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - dateFormatter
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - IB Actions
    @IBAction private func likeButtonTapped(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    // MARK: - Public methods
    func setIsLiked(_ isLiked: Bool) {
        let imageName = isLiked ? "activeLike" : "inactiveLike"
        likeButton.setImage(UIImage(named: imageName), for: .normal)
    }
   
    func configCell(with url: URL, indexPath: IndexPath) {
        if let date = ImagesListService.shared.photos[indexPath.row].createdAt {
            dataLabel.text = dateFormatter.string(from: date)
        }
        else {
            dataLabel.text = ""
        }
        applyGradient(to: gradientView)
        setIsLiked(ImagesListService.shared.photos[indexPath.row].isLiked)
        ImageView.kf.indicatorType = .activity
        ImageView.kf.setImage(with: url, placeholder: UIImage(named: "stub")) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.ImageLoaded(self)
        }
    }
    
    // MARK: - Private method 
    private func applyGradient(to view: UIView) {
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
    
    // MARK: - Properties
    static let reuseIdentifier = "ImagesListCell"
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ImageView.kf.cancelDownloadTask()
    }
}
