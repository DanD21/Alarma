//
//  AlarmCreationController.swift
//  Alarma
//
//  Created by Dan Danilescu on 11/6/18.
//  Copyright © 2018 Endava. All rights reserved.
//

import UIKit
import RealmSwift

class AlarmCreationController: UIViewController, AlarmView {
  
//  var onCreateAlarm: ((RealmAlarm) -> Void)?
  var onAlarmCreated: ((Alarm) -> Void)?

  @IBOutlet weak var datePicker: UIDatePicker!
  @IBOutlet weak var tableView: UITableView!
  
  var realm: Realm!
  var group: Group!
  var alarm: RealmAlarm?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    realm = try! Realm()
    setupUI()
  }
  
  func setupUI() {
    title = "New Alarm"
    tableView.register(cellType: DetailTableViewCell.self)
    tableView.register(cellType: SwitchTableViewCell.self)
    tableView.tableFooterView = UIView()
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .save,
      target: self,
      action: #selector(AlarmCreationController.saveAlarmButtonClicked(_:))
    )
  }
  
  @objc func saveAlarmButtonClicked(_ sender: UIBarButtonItem) {
    let alarm = Alarm.init(groupID: group.groupID,
                           groupName: group.groupName,
                           time: datePicker.date,
                           isEnabled: false,
                           sound: "Default",
                           loopSound: false,
                           repeatDays: [])
    onAlarmCreated?(alarm)
  }
}

extension AlarmCreationController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: DetailTableViewCell = tableView.dequeueReusableCell(for: indexPath)
    switch indexPath.row {
    case 0:
      let viewModel = PlainCellViewModel.init(title: "Repeat", subtitle: "Never")
      cell.configure(with: viewModel)
      return cell
    case 1:
      let viewModel = PlainCellViewModel.init(title: "Sound", subtitle: "Rock")
       cell.configure(with: viewModel)
      return cell
    case 2:
      let cell: SwitchTableViewCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure()
      cell.selectionStyle = .none
      return cell
    default:
      return cell
    }
  }
}
