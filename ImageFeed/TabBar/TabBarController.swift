import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        tabBar.barTintColor = UIColor.ypBlack
        tabBar.backgroundColor = UIColor.ypBlack
        tabBar.tintColor = UIColor.ypWhite
        tabBar.unselectedItemTintColor = UIColor.ypWhiteAlpha50
        tabBar.isTranslucent = false
        
        let imageListViewController = ImagesListViewController()
        imageListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil
        )
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "TabProfileActive"),
            selectedImage: nil
        )
        self.viewControllers = [imageListViewController, profileViewController]
        addShadow()
    }
    
    private func addShadow() {
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.3
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -0.5)
        tabBar.layer.masksToBounds = false
    }
}
