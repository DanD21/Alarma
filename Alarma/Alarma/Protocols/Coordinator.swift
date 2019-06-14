//
//  Coordinator.swift
//  Alarma
//
//  Created by Dan Danilescu on 10/24/18.
//  Copyright © 2018 Dan Danilescu. All rights reserved.
//

import Foundation

protocol Coordinator: class {
  func start()
  func start(with option: DeepLinkOption?)
}
