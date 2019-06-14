//
//  OnboardingController.swift
//  Alarma
//
//  Created by Dan Danilescu on 10/24/18.
//  Copyright © 2018 Dan Danilescu. All rights reserved.
//

import UIKit

class OnboardingController: UIViewController, OnboardingView {
  
  var onFinish: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

  @IBAction func startButtonTapped(_ sender: Any) {
    onFinish?()
  }
  
}
