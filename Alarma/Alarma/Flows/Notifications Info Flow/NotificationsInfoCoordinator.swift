//
//  InfoCoordinator.swift
//  Alarma
//
//  Created by Dan Danilescu on 10/24/18.
//  Copyright © 2018 Dan Danilescu. All rights reserved.
//

import Foundation

final class NotificationsInfoCoordinator: BaseCoordinator, NotificationsInfoCoordinatorOutput {
  
  var finishFlow: (() -> Void)?
  
  private let factory: NotificationsInfoModuleFactory
  private let router: Router
  
  init(router: Router, factory: NotificationsInfoModuleFactory) {
    self.factory = factory
    self.router = router
  }
  
  override func start() {
    showNotificationsPermissionScreen()
  }
  
  // MARK: - Run current flow's controllers
  
  private func showNotificationsPermissionScreen() {
    let screenOutput = factory.makeNotificationsPermissionOutput()
    screenOutput.onPermissionsGranted = { [weak self] in
      self?.finishFlow?()
    }
    screenOutput.onPermissionsDenied = { [weak self] in
      self?.showNotificationsDeniedScreen()
    }
    router.setRootModule(screenOutput)
  }
  
  private func showNotificationsDeniedScreen() {
    let notificationsDeniedView = factory.makeDeniedViewOutput()
    notificationsDeniedView.onPermissionsGranted = { [weak self] in
      self?.finishFlow?()
    }
    router.push(notificationsDeniedView)
  }
}
