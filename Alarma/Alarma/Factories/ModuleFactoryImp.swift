//
//  ModuleFactoryImp.swift
//  Alarma
//
//  Created by Dan Danilescu on 10/24/18.
//  Copyright © 2018 Dan Danilescu. All rights reserved.
//

import UIKit

final class ModuleFactoryImp: AuthModuleFactory,
  OnboardingModuleFactory,
  NotificationsInfoModuleFactory,
  GroupModuleFactory,
  GroupCreateModuleFactory,
  SettingsModuleFactory {
  
  func makeLoginOutput() -> LoginView {
    return LoginController()
  }
  
  func makeSignUpHandler() -> SignUpView {
    return SignUpController()
  }
  
  func makeOnboardingModule() -> OnboardingView {
    return OnboardingController()
  }
  
  func makeNotificationsPermissionOutput() -> NotificationsPermissionView {
    return NotificationsPermissionViewController()
  }
  
  func makeDeniedViewOutput() -> NotificationsDeniedView {
    return NotificationsDeniedViewController()
  }
  
  func makeGroupsOutput() -> GroupsListView {
    return GroupsListController()
  }
  
  func makeGroupDetailOutput(group: Group) -> GroupDetailView {
    
    let controller = GroupDetailController()
    controller.group = group
    return controller
  }
  
  func makeAlarmOutput(group: Group) -> AlarmView {
    let controller = AlarmCreationController()
    controller.group = group
    return controller    
  }
  
  func makeGroupAddOutput() -> GroupCreateView {
    return GroupCreateController()
  }
  
  func makeSettingsOutput() -> SettingsView {
    return SettingsController()
  }
}
