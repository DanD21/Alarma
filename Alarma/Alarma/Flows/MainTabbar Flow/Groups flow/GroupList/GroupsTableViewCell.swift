//
//  GroupsTableViewCell.swift
//  Alarma
//
//  Created by Dan Danilescu on 11/13/18.
//  Copyright © 2018 Endava. All rights reserved.
//

import UIKit
import Reusable

protocol GroupsTableViewCellDelegate: class {
  func groupsTableViewDidTapSwitch(_ sender: GroupsTableViewCell)
}

class GroupsTableViewCell: UITableViewCell, NibReusable {

  @IBOutlet weak var groupNameLabel: UILabel!
  @IBOutlet weak var groupIntervalLabel: UILabel!
  @IBOutlet weak var activationSwitch: UISwitch!
  
  weak var delegate: GroupsTableViewCellDelegate?
  
  func configure(with item: GroupViewModel) {
    groupNameLabel.text = item.groupName
    groupIntervalLabel.text = item.interval
    activationSwitch.isOn = item.isEnabled
  }
  
  @IBAction func didSwitch(sender: UISwitch) {
    delegate?.groupsTableViewDidTapSwitch(self)
  }
}
