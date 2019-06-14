//
//  Presentable.swift
//  Alarma
//
//  Created by Dan Danilescu on 10/24/18.
//  Copyright © 2018 Dan Danilescu. All rights reserved.
//

import UIKit

protocol Presentable {
  func toPresent() -> UIViewController?
}

extension UIViewController: Presentable {
  func toPresent() -> UIViewController? {
    return self
  }
}
