//
//  TabbarController.swift
//  Alarma
//
//  Created by Dan Danilescu on 10/24/18.
//  Copyright © 2018 Dan Danilescu. All rights reserved.
//

import UIKit

final class TabbarController: UITabBarController, UITabBarControllerDelegate, TabbarView {
  
  var onGroupFlowSelect: ((UINavigationController) -> Void)?
  var onSettingsFlowSelect: ((UINavigationController) -> Void)?
  var onViewDidLoad: ((UINavigationController) -> Void)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    delegate = self
  }
  
  func startFlow() {
    if let controller = customizableViewControllers?.first as? UINavigationController {
      onViewDidLoad?(controller)
      self.selectedIndex = 0
    }
  }
  
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    guard let controller = viewControllers?[selectedIndex] as? UINavigationController else { return }
    
    if selectedIndex == 0 {
      onGroupFlowSelect?(controller)
    } else if selectedIndex == 1 {
      onSettingsFlowSelect?(controller)
    }
  }
}
