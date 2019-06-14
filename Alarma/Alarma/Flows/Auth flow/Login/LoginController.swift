//
//  LoginController.swift
//  Alarma
//
//  Created by Dan Danilescu on 10/24/18.
//  Copyright © 2018 Dan Danilescu. All rights reserved.
//

import UIKit

class LoginController: UIViewController, LoginView {
  
  var onCompleteAuth: (() -> Void)?
  var onSignUpButtonTap: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
  
  @IBAction func loginButtonTapped(_ sender: Any) {
    onCompleteAuth?()
  }
  
  @IBAction func signUpButtonTapped(_ sender: Any) {
    onSignUpButtonTap?()
  }
}
