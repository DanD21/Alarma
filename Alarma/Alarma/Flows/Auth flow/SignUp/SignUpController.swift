//
//  SignUpController.swift
//  Alarma
//
//  Created by Dan Danilescu on 10/25/18.
//  Copyright © 2018 Dan Danilescu. All rights reserved.
//

import UIKit

class SignUpController: UIViewController, SignUpView {
  
  var onSignUpComplete: (() -> Void)?
  var onCancelButtonTap: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
  
  @IBAction func signUpButtonPressed(_ sender: Any) {
    onSignUpComplete?()
  }
  
  @IBAction func cancelButtonPressed(_ sender: Any) {
    onCancelButtonTap?()
  }
}
