import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    // MARK: - IB Outlets
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - IB Actions
    @IBAction func likeButtonTapped(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    // MARK: - Public methods
    func setIsLiked(_ isLiked: Bool) {
        let imageName = isLiked ? "activeLike" : "inactiveLike"
        likeButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    // MARK: - Properties
    static let reuseIdentifier = "ImagesListCell"
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ImageView.kf.cancelDownloadTask()
    }
}
