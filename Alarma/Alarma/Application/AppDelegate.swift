//
//  AppDelegate.swift
//  Alarma
//
//  Created by Dan Danilescu on 10/24/18.
//  Copyright © 2018 Dan Danilescu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var rootController: UINavigationController {
    // swiftlint:disable force_cast
    return self.window!.rootViewController as! UINavigationController
    // swiftlint:enable force_cast
  }
  
  private lazy var applicationCoordinator: Coordinator = self.makeCoordinator()
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let notification = launchOptions?[.remoteNotification] as? [String: AnyObject]
    let deepLink = DeepLinkOption.build(with: notification)
    
    setupWindow()
    applicationCoordinator.start(with: deepLink)
    return true
  }
  
  private func makeCoordinator() -> Coordinator {
    return ApplicationCoordinator(
      router: RouterImp(rootController: self.rootController),
      coordinatorFactory: CoordinatorFactoryImp()
    )
  }
  
  // MARK: Handle push notifications and deep links
  func application(_ application: UIApplication,
                   didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    let dict = userInfo as? [String: AnyObject]
    let deepLink = DeepLinkOption.build(with: dict)
    applicationCoordinator.start(with: deepLink)
  }
  
  private func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    let deepLink = DeepLinkOption.build(with: userActivity)
    applicationCoordinator.start(with: deepLink)
    return true
  }
  
  private func setupWindow() {
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = UINavigationController()
    window?.makeKeyAndVisible()
    window?.tintColor = UIColor(red:0.44, green:0.69, blue:0.24, alpha:1.0)
  }
}
