//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by user on 23.11.2024.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    // MARK: - IB Outlets
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    // MARK: - Properties
    static let reuseIdentifier = "ImagesListCell"
}
