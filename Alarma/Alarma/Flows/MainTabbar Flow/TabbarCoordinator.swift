//
//  TabbarCoordinator.swift
//  Alarma
//
//  Created by Dan Danilescu on 10/24/18.
//  Copyright © 2018 Dan Danilescu. All rights reserved.
//

import UIKit

class TabbarCoordinator: BaseCoordinator {
  
  private let tabbarView: TabbarView
  private let coordinatorFactory: CoordinatorFactory
  
  init(tabbarView: TabbarView, coordinatorFactory: CoordinatorFactory) {
    self.tabbarView = tabbarView
    self.coordinatorFactory = coordinatorFactory
  }
  
  override func start() {
    tabbarView.onViewDidLoad = runGroupFlow()
    tabbarView.startFlow()
    tabbarView.onGroupFlowSelect = runGroupFlow()
    tabbarView.onSettingsFlowSelect = runSettingsFlow()
  }
  
  private func runGroupFlow() -> ((UINavigationController) -> Void) {
    return { [unowned self] navController in
      if navController.viewControllers.isEmpty == true {
        let groupCoordinator = self.coordinatorFactory.makeGroupCoordinator(navController: navController)
        self.addDependency(groupCoordinator)
        groupCoordinator.start()
      }
    }
  }
  
  private func runSettingsFlow() -> ((UINavigationController) -> Void) {
    return { [unowned self] navController in
      if navController.viewControllers.isEmpty == true {
        let settingsCoordinator = self.coordinatorFactory.makeSettingsCoordinator(navController: navController)
        self.addDependency(settingsCoordinator)
        settingsCoordinator.start()
      }
    }
  }
}
