//
//  CoordinatorFactoryImp.swift
//  Alarma
//
//  Created by Dan Danilescu on 10/24/18.
//  Copyright © 2018 Dan Danilescu. All rights reserved.
//

import UIKit

enum Tab: String {
  case home
  case settings
  
  var selectedImage: UIImage? {
    switch self {
    case .home:
      return UIImage(named: "alarm")
    case .settings:
      return  UIImage(named: "settings")
    }
  }
  
  var title: String {
    
    switch self {
    case .home:
      return  NSLocalizedString(self.rawValue, comment: "")
    case .settings:
      return  NSLocalizedString(self.rawValue, comment: "")
    }
  }
  
  static var all: [Tab] = [.home, .settings]
}

final class CoordinatorFactoryImp: CoordinatorFactory {
  
  func makeTabbarCoordinator() -> (configurator: Coordinator, toPresent: Presentable?) {
    let controller = TabbarController()
    
    var controllers: [UINavigationController] = []
    
    for tab in Tab.all {
      let controller = UINavigationController()
      let tabbarItem = UITabBarItem.init(title: tab.title, image: tab.selectedImage, tag: 0)
      controller.tabBarItem = tabbarItem
      controllers.append(controller)
    }
    controller.viewControllers = controllers
    
    let coordinator = TabbarCoordinator(tabbarView: controller, coordinatorFactory: CoordinatorFactoryImp())
    return (coordinator, controller)
  }
  
  func makeAuthCoordinatorBox(router: Router) -> Coordinator & AuthCoordinatorOutput {
    
    let coordinator = AuthCoordinator(router: router, factory: ModuleFactoryImp())
    return coordinator
  }
  
  func makeNotificationsInfoCoordinator(router: Router) -> Coordinator & NotificationsInfoCoordinatorOutput {
    let coordinator = NotificationsInfoCoordinator(router: router, factory: ModuleFactoryImp())
    return coordinator
  }
  
  func makeGroupCoordinator() -> Coordinator {
    return makeGroupCoordinator(navController: nil)
  }
  
  func makeOnboardingCoordinator(router: Router) -> Coordinator & OnboardingCoordinatorOutput {
    return OnboardingCoordinator(with: ModuleFactoryImp(), router: router)
  }
  
  func makeGroupCoordinator(navController: UINavigationController?) -> Coordinator {
    let coordinator = GroupCoordinator(
      router: router(navController),
      factory: ModuleFactoryImp(),
      coordinatorFactory: CoordinatorFactoryImp()
    )
    return coordinator
  }
  
  func makeSettingsCoordinator() -> Coordinator {
    return makeSettingsCoordinator(navController: nil)
  }
  
  func makeSettingsCoordinator(navController: UINavigationController? = nil) -> Coordinator {
    let coordinator = SettingsCoordinator(router: router(navController), factory: ModuleFactoryImp())
    return coordinator
  }
  
  func makeGroupCreationCoordinatorBox() ->
    (configurator: Coordinator & GroupCreateCoordinatorOutput,
    toPresent: Presentable?) {
      
      return makeGroupCreationCoordinatorBox(navController: navigationController(nil))
  }
  func makeGroupCreationCoordinatorBox(navController: UINavigationController?) ->
    (configurator: Coordinator & GroupCreateCoordinatorOutput,
    toPresent: Presentable?) {
      
      let router = self.router(navController)
      let coordinator = GroupCreateCoordinator(router: router, factory: ModuleFactoryImp())
      return (coordinator, router)
  }
  
  private func router(_ navController: UINavigationController?) -> Router {
    return RouterImp(rootController: navigationController(navController))
  }
  
  private func navigationController(_ navController: UINavigationController?) -> UINavigationController {
    if let navController = navController { return navController } else { return UINavigationController() }
  }
}
