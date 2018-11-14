//
//  NavigationController.swift
//  Affirmation
//
//  Created by 執行健人 on 2017/07/30.
//  Copyright © 2017年 Kento. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        
        //ナビゲーションバーの高さを設定する。
        self.navigationBar.frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: UIScreen.main.bounds.size.width, height: 40)
            }
}
