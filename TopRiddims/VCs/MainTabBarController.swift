//
//  MainTabBarController.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/15/21.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabs()
    }
    
    private func configureTabs(){
        
//        tabBar.itemPositioning = .centered //itemの配置の仕方。必要ないかも。
        tabBar.tintColor = UIColor(named: "Black_Yellow")
        let configuration = UIImage.SymbolConfiguration(weight: .thin)
        
        //実際はFireBaseからcountriesを事前にDLして格納した後chartVCを作る。
        let chartVC = ChartVC(countries: [K.Country.haiti, K.Country.jamaica])
        let chartNav = generateNavController(rootVC: chartVC,
                                             title: "charts",
                                             selectedImage: UIImage(systemName: "bolt.fill", withConfiguration: configuration)!,
                                             unselectedImage: UIImage(systemName: "bolt", withConfiguration: configuration)!)
        
        let likesVC = LikesVC()
        let likesNav = generateNavController(rootVC: likesVC,
                                             title: "likes",
                                             selectedImage: UIImage(systemName: "suit.heart.fill", withConfiguration: configuration)!,
                                             unselectedImage: UIImage(systemName: "suit.heart", withConfiguration: configuration)!)
        
        let settingVC = SettingVC()
        let settingNav = generateNavController(rootVC: settingVC,
                                               title: "setting",
                                               selectedImage: UIImage(systemName: "person.fill", withConfiguration: configuration)!,
                                               unselectedImage: UIImage(systemName: "person", withConfiguration: configuration)!)
        
        
        self.viewControllers = [chartNav, likesNav, settingNav]
    }
    
    private func generateNavController(rootVC: UIViewController, title: String, selectedImage: UIImage, unselectedImage: UIImage) -> UINavigationController{
        rootVC.tabBarItem.title = title
        rootVC.tabBarItem.selectedImage = selectedImage
        rootVC.tabBarItem.image = unselectedImage
        let nav = UINavigationController(rootViewController: rootVC)
        nav.navigationBar.tintColor = UIColor(named: "Black_Yellow")!
        return nav
    }
    
}
