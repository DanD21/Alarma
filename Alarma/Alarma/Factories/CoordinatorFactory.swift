//
//  CoordinatorFactory.swift
//  Alarma
//
//  Created by Dan Danilescu on 10/24/18.
//  Copyright © 2018 Dan Danilescu. All rights reserved.
//

import UIKit

protocol CoordinatorFactory {
  
  func makeTabbarCoordinator() -> (configurator: Coordinator, toPresent: Presentable?)
  func makeAuthCoordinatorBox(router: Router) -> Coordinator & AuthCoordinatorOutput
  
  func makeOnboardingCoordinator(router: Router) -> Coordinator & OnboardingCoordinatorOutput
  
  func makeNotificationsInfoCoordinator(router: Router) -> Coordinator & NotificationsInfoCoordinatorOutput
  
  func makeGroupCoordinator(navController: UINavigationController?) -> Coordinator
  func makeGroupCoordinator() -> Coordinator
  
  func makeSettingsCoordinator() -> Coordinator
  func makeSettingsCoordinator(navController: UINavigationController?) -> Coordinator
  
  func makeGroupCreationCoordinatorBox() ->
    (configurator: Coordinator & GroupCreateCoordinatorOutput,
    toPresent: Presentable?)
  
  func makeGroupCreationCoordinatorBox(navController: UINavigationController?) ->
    (configurator: Coordinator & GroupCreateCoordinatorOutput,
    toPresent: Presentable?)
}
