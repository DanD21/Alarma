//
//  GroupDetailController.swift
//  Alarma
//
//  Created by Dan Danilescu on 10/24/18.
//  Copyright © 2018 Dan Danilescu. All rights reserved.
//

import UIKit
import RealmSwift

final class GroupDetailController: UIViewController, GroupDetailView, AlarmsTableViewCellDelegate {
  
  var onCreateAlarmButtonTapped: ((Group) -> Void)?
//  var onBackButtonTapped: (() -> Void)?
  
  @IBOutlet weak var tableView: UITableView!
  
  var repository: GroupRepository = GroupRepositoryImp()
  var alarmRepository: AlarmRepository = AlarmRepositoryImp()
  
  var group: Group!
  var alarms = [Alarm]()

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    refresh()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    refresh()
  }
  
  private func refresh() {
    alarms = alarmRepository.fetchAllAlarms(group: group)
    tableView.reloadData()
  }
  
  func setupUI() {
    title = group.groupName
    tableView.register(cellType: AlarmsTableViewCell.self)
    
    let addButton = UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self,
      action: #selector(GroupDetailController.addAlarmButtonClicked(_:))
    )
    navigationItem.rightBarButtonItems = [addButton, editButtonItem]
  }
  
  func alarmsTableViewDidTapSwitch(_ sender: AlarmsTableViewCell) {
    guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
    try? alarmRepository.enable(alarm: alarms[tappedIndexPath.row], isEnabled: sender.alarmSwitch.isOn)
  }
  
  @objc func addAlarmButtonClicked(_ sender: UIBarButtonItem) {
    onCreateAlarmButtonTapped?(group)
  }
}

extension GroupDetailController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return alarms.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: AlarmsTableViewCell = tableView.dequeueReusableCell(for: indexPath)
    let cellModel = alarms[indexPath.row]
//    let cellModel =  group.alarmList[indexPath.row]
    cell.configure(with: cellModel.toViewModel())
    cell.delegate = self
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }

  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    return .delete
  }
  
  override func setEditing(_ editing: Bool, animated: Bool) { super.setEditing(editing, animated: animated)
    tableView!.setEditing(editing, animated: animated)
  }
  
  public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      try? alarmRepository.remove(alarm: alarms.remove(at: indexPath.row))
      tableView.deleteRows(at: [indexPath], with: .automatic)
    }
  }
}
