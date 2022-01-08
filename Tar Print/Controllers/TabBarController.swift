//
//  TabBarController.swift
//  Tar Print Draft 4
//
//  Created by Suraj Vaddi on 9/13/20.
//  Copyright © 2020 Suraj Vaddi. All rights reserved.
//

import UIKit
import MapKit

class TabBarController: UITabBarController {
    
    //MARK: - View Load
    //view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 0
        self.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        delegate = self
    }
}

//MARK: - TabBarController
extension TabBarController: UITabBarControllerDelegate  {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
          return false // Make sure you want this as false
        }

        if fromView != toView {
            UIView.transition(from: fromView, to: toView, duration: 0.1, options: [.transitionCrossDissolve], completion: nil)
        }

        return true
    }
}
