//
//  ViewController.swift
//  ImageFeed
//
//  Created by user on 21.11.2024.
//

import UIKit

class ImagesListViewController: UIViewController {
    @IBOutlet private var TableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{"\($0)"}
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        // Do any additional setup after loading the view.
    }
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    
}

extension ImagesListViewController {

    
    func applyGradient(to view: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.ypBlackAlpha0.cgColor, UIColor.ypBlackAlpha02.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        applyGradient(to: cell.gradientView)
        guard let image = UIImage(named: photosName[indexPath.row]) else {return}
        cell.ImageView.image = image
        cell.dataLabel.text = dateFormatter.string(from: Date())
        cell.likeButton.imageView?.image = UIImage(named: indexPath.row%2 == 0 ? "icActive" : "noActive")
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        
        let ratio = (tableView.frame.width - imageInsets.left - imageInsets.right) / image.size.width
        let height = ratio * image.size.height + imageInsets.top + imageInsets.bottom
        return height
    }
}
