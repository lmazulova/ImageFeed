//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by user on 18.12.2024.
//

import UIKit

final class AuthViewController: UIViewController {
    
    @IBOutlet weak var loginBtn: UIButton!
    override func viewDidLoad() {
        loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
    }
}
