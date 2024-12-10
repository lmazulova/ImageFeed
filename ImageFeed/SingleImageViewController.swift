//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by user on 10.12.2024.
//

import UIKit
final class SingleImageViewController: UIViewController {
    var image: UIImage?
    @IBOutlet weak private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
}
