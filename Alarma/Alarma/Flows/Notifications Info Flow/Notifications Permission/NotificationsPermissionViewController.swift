//
//  NotificationsPermissionViewController.swift
//  Alarma
//
//  Created by Dan Danilescu on 10/24/18.
//  Copyright © 2018 Dan Danilescu. All rights reserved.
//

import UIKit
import Lottie

class NotificationsPermissionViewController: UIViewController, NotificationsPermissionView {
  
  var onPermissionsGranted: (() -> Void)?
  var onPermissionsDenied: (() -> Void)?
  
    override func viewDidLoad() {
        super.viewDidLoad()

      let animationView = LOTAnimationView(name: "notification")
      animationView.frame = CGRect(x: 10, y: 0, width: 200, height: 200)
      animationView.center = self.view.center
      animationView.contentMode = .scaleAspectFill
      animationView.loopAnimation = true
      view.addSubview(animationView)
      
      animationView.play()
    }

  @IBAction func allowButtonPressed(_ sender: Any) {
    onPermissionsGranted?()
  }
  
  @IBAction func denyButtonPressed(_ sender: Any) {
    onPermissionsDenied?()
  }

}
