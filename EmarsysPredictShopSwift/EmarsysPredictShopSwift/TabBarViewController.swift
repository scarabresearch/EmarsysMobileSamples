//
//  TabBarViewController.swift
//  EmarsysPredictShopSwift
//
//

import UIKit

class TabBarViewController: UITabBarController {
    
    @IBInspectable var tabBarItemTintColor: UIColor?
    
    override func viewDidLoad() {
        // Update all UITabBars' tint color
        UITabBar.appearance().tintColor = tabBarItemTintColor
    }
}
