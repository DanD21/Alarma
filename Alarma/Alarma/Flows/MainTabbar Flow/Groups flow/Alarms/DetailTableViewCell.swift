//
//  DetailTableViewCell.swift
//  Alarma
//
//  Created by Dan Danilescu on 12/6/18.
//  Copyright © 2018 Endava. All rights reserved.
//

import UIKit
import Reusable

enum SimpleCellType {
  case repeatCell
  case soundCell
}

class DetailTableViewCell: UITableViewCell, NibReusable {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var detailLabel: UILabel!
  
  func configure(with viewModel: PlainCellViewModel) {
//    switch type {
//    case .repeatCell:
//      titleLabel.text = "Repeat"
//      detailLabel.text = "Never"
//    case .soundCell:
//      titleLabel.text = "Sound"
//      detailLabel.text = "Siren"
//    }
    titleLabel.text = viewModel.title
    detailLabel.text = viewModel.subtitle
  }
}

struct PlainCellViewModel {
  let title: String
  let subtitle: String
}
