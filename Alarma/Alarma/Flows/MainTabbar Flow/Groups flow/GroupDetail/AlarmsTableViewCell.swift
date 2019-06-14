//
//  AlarmsTableViewCell.swift
//  Alarma
//
//  Created by Dan Danilescu on 12/3/18.
//  Copyright © 2018 Endava. All rights reserved.
//

import UIKit
import Reusable

protocol AlarmsTableViewCellDelegate: class {
  func alarmsTableViewDidTapSwitch(_ sender: AlarmsTableViewCell)
}

class AlarmsTableViewCell: UITableViewCell, NibReusable {

  @IBOutlet weak var alarmTimeLabel: UILabel!
  @IBOutlet weak var alarmSwitch: UISwitch!
  
  weak var delegate: AlarmsTableViewCellDelegate?
  
  func configure(with item: AlarmViewModel) {
    let timeFormatter = DateFormatter()
    timeFormatter.timeStyle = .short
    
    alarmTimeLabel.text = timeFormatter.string(from: item.time)
    alarmSwitch.isOn = item.isEnabled
  }
  
  @IBAction func didTapActivationSwitch(sender: UISwitch) {
    delegate?.alarmsTableViewDidTapSwitch(self)
  }
}
