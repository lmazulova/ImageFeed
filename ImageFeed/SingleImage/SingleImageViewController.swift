
import UIKit
import Kingfisher
final class SingleImageViewController: UIViewController {
    
    var imageUrl: URL?
    
    // MARK: - IB Outlets
    @IBOutlet weak private var backButton: UIButton!
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var sharingBtn: UIButton!
    @IBOutlet weak private var imageView: UIImageView!
    
    // MARK: - IB Actions
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction private func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(share, animated: true, completion: nil)
    }
    
    func showError() {
        
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        sharingBtn.setTitle("", for: .normal)
        scrollView.minimumZoomScale = 0.05
        scrollView.maximumZoomScale = 1.25
        guard let url = imageUrl else { return }
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: url) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.imageView.frame.size = imageResult.image.size
                self.scrollView.contentSize = imageResult.image.size
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showError()
            }
        }
    }
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        guard let image = imageView.image else { return }
        centerImageInScrollView(image: image)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        imageView.frame.origin = CGPoint(x: 0, y: 0)
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.height/imageSize.height
        let wScale = visibleRectSize.width/imageSize.width
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, wScale)))
        scrollView.setZoomScale(scale, animated: false)
        centerImageInScrollView(image: image)
        scrollView.layoutIfNeeded()
    }
    
    private func centerImageInScrollView(image: UIImage) {
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let newContentSize = scrollView.contentSize
        let horizontalInset = (visibleRectSize.width - newContentSize.width) / 2
        let verticalInset =  (visibleRectSize.height - newContentSize.height) / 2
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
}

