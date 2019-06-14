//
//  NotificationsDeniedViewController.swift
//  Alarma
//
//  Created by Dan Danilescu on 10/24/18.
//  Copyright © 2018 Dan Danilescu. All rights reserved.
//

import UIKit

class NotificationsDeniedViewController: UIViewController, NotificationsDeniedView {
  
  var onPermissionsGranted: (() -> Void)?
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
  
  @IBAction func goToSettingsButtonPressed(_ sender: Any) {
    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
      return
    }
    if UIApplication.shared.canOpenURL(settingsUrl) {
      UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
        print("Settings opened: \(success)")
        self.onPermissionsGranted?()
      })
    }
  }
}
