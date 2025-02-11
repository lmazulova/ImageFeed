import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Views
    private let likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "inactiveLike"), for: .normal)
        
        return button
    }()
    
    private let photoView: UIImageView = {
        let photoView = UIImageView()
        photoView.contentMode = .scaleAspectFill
        photoView.layer.cornerRadius = 16
        photoView.layer.masksToBounds = true
        photoView.translatesAutoresizingMaskIntoConstraints = false
        return photoView
    }()
    
    private let gradientView: UIView = {
        let gradientView = UIView()
        gradientView.backgroundColor = .clear
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        return gradientView
    }()
    
    private let dataLabel: UILabel = {
        let dataLabel = UILabel()
        dataLabel.translatesAutoresizingMaskIntoConstraints = false
        dataLabel.font = UIFont.systemFont(ofSize: 13)
        dataLabel.textColor = .white
        return dataLabel
    }()
    
    private func setupUI() {
        contentView.addSubview(photoView)
        contentView.addSubview(likeButton)
        contentView.addSubview(gradientView)
        contentView.addSubview(dataLabel)
        backgroundColor = .clear
        NSLayoutConstraint.activate([
            photoView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            photoView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            photoView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 4),
            photoView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -4),
            
            likeButton.trailingAnchor.constraint(equalTo: photoView.trailingAnchor, constant: 0),
            likeButton.topAnchor.constraint(equalTo: photoView.topAnchor, constant: 0),
            likeButton.heightAnchor.constraint(equalToConstant: 44),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            
            gradientView.trailingAnchor.constraint(equalTo: photoView.trailingAnchor),
            gradientView.leadingAnchor.constraint(equalTo: photoView.leadingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: photoView.bottomAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 30),
            
            dataLabel.bottomAnchor.constraint(equalTo: photoView.bottomAnchor, constant: -6),
            dataLabel.leadingAnchor.constraint(equalTo: photoView.leadingAnchor, constant: 8),
            dataLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Delegate
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - dateFormatter
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - likeButtonTarget
    @objc private func likeButtonTapped() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    // MARK: - Public methods
    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradient(to: gradientView)
    }
    
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
//        applyGradient(to: gradientView)
        setIsLiked(ImagesListService.shared.photos[indexPath.row].isLiked)
        photoView.kf.indicatorType = .activity
        photoView.kf.setImage(with: url, placeholder: UIImage(named: "stub")) { [weak self] _ in
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
        photoView.kf.cancelDownloadTask()
    }
}
