//
//  TabbarView.swift
//  Alarma
//
//  Created by Dan Danilescu on 10/24/18.
//  Copyright © 2018 Dan Danilescu. All rights reserved.
//

import UIKit

protocol TabbarView: class {
  var onGroupFlowSelect: ((UINavigationController) -> Void)? { get set }
  var onSettingsFlowSelect: ((UINavigationController) -> Void)? { get set }
  var onViewDidLoad: ((UINavigationController) -> Void)? { get set }
  
  func startFlow()
}
