//
//  SwitchTableViewCell.swift
//  Alarma
//
//  Created by Dan Danilescu on 12/6/18.
//  Copyright © 2018 Endava. All rights reserved.
//

import UIKit
import Reusable

class SwitchTableViewCell: UITableViewCell, NibReusable {

  @IBOutlet weak var repeatLabel: UILabel!
  @IBOutlet weak var repeatSwitch: UISwitch!
  
  func configure() {
    repeatLabel.text = "Loop sound"
    repeatSwitch.isOn = true
  }
}
