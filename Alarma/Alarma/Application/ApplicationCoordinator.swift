//
//  ApplicationCoordinator.swift
//  Alarma
//
//  Created by Dan Danilescu on 10/24/18.
//  Copyright © 2018 Dan Danilescu. All rights reserved.
//

import Foundation

private var onboardingWasShown = false
private var isAuthorized = false
private var notificationsAllowed = false

private enum LaunchInstructor {
  case main, auth, onboarding, notificationsInfo
  
  static func configure(
    tutorialWasShown: Bool = onboardingWasShown,
    isAuthorized: Bool = isAuthorized,
    notificationsAllowed: Bool = notificationsAllowed) -> LaunchInstructor {
    
    switch (tutorialWasShown, isAuthorized, notificationsAllowed) {
    case (_, false, _): return .auth
    case (false, true, false), (false, true, true): return .onboarding
    case (true, true, false): return .notificationsInfo
    case (true, true, true): return .main
    }
  }
}

final class ApplicationCoordinator: BaseCoordinator {
  
  private let coordinatorFactory: CoordinatorFactory
  private let router: Router
  
  private var instructor: LaunchInstructor {
    return LaunchInstructor.configure()
  }
  
  init(router: Router, coordinatorFactory: CoordinatorFactory) {
    self.router = router
    self.coordinatorFactory = coordinatorFactory
  }
  
  override func start(with option: DeepLinkOption?) {

      switch instructor {
      case .onboarding: runOnboardingFlow()
      case .auth: runAuthFlow()
      case .main: runMainFlow()
      case .notificationsInfo: runNotificationsInfoFlow()
      }
  }
  
  private func runAuthFlow() {
    let coordinator = coordinatorFactory.makeAuthCoordinatorBox(router: router)
    coordinator.finishFlow = { [weak self, weak coordinator] in
      isAuthorized = true
      self?.start()
      self?.removeDependency(coordinator)
    }
    addDependency(coordinator)
    coordinator.start()
  }
  
  private func runOnboardingFlow() {
    let coordinator = coordinatorFactory.makeOnboardingCoordinator(router: router)
    coordinator.finishFlow = { [weak self, weak coordinator] in
      onboardingWasShown = true
      self?.start()
      self?.removeDependency(coordinator)
    }
    addDependency(coordinator)
    coordinator.start()
  }
  
  private func runNotificationsInfoFlow() {
    let coordinator = coordinatorFactory.makeNotificationsInfoCoordinator(router: router)
    coordinator.finishFlow = { [weak self, weak coordinator] in
      notificationsAllowed = true
      self?.start()
      self?.removeDependency(coordinator)
    }
    addDependency(coordinator)
    coordinator.start()
  }
  
  private func runMainFlow() {
    let (coordinator, module) = coordinatorFactory.makeTabbarCoordinator()
    addDependency(coordinator)
    router.setRootModule(module, hideBar: true)
    coordinator.start()
  }
}
