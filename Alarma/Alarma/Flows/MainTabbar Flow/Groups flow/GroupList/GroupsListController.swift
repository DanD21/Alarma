//
//  GroupsListController.swift
//  Alarma
//
//  Created by Dan Danilescu on 10/24/18.
//  Copyright © 2018 Dan Danilescu. All rights reserved.
//

import UIKit
import Reusable
import RealmSwift

final class GroupsListController: UIViewController, GroupsListView, GroupsTableViewCellDelegate {
  
  //controller handler
  var onGroupSelect: ((Group) -> Void)?
  var onCreateGroup: ((Group) -> Void)?
  
  @IBOutlet weak var tableView: UITableView!
  
  var groupRepository: GroupRepository = GroupRepositoryImp()
  
  var groups = [Group]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    refresh()
  }
  
  private func refresh() {
    groups = groupRepository.fetchAllGroups()
    tableView.reloadData()
  }
  
  func setupUI() {
    title = "Alarms"
    tableView.register(cellType: GroupsTableViewCell.self)
    
    navigationItem.leftBarButtonItem = editButtonItem
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self,
      action: #selector(GroupsListController.addGroupButtonClicked(_:))
    )
  }
  
  @objc func addGroupButtonClicked(_ sender: UIBarButtonItem) {
    let alertController = UIAlertController(title: "Add New Group", message: "and add new alarms", preferredStyle: UIAlertController.Style.alert)
    
    let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { [unowned self] _ in
      let groupNameTextField = alertController.textFields![0] as UITextField
      let newGroup = Group(groupName: groupNameTextField.text ?? "New Group")
      
      let savedGroup = try? self.groupRepository.save(group: newGroup)
      
      self.refresh()
      guard let group = savedGroup?.toModel() else { return }
      self.onCreateGroup?(group)
    })
    
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {(_: UIAlertAction!) -> Void in })
    alertController.addTextField { (textField: UITextField!) -> Void in
      textField.placeholder = "To work"
    }
    alertController.addAction(saveAction)
    alertController.addAction(cancelAction)
    
    self.present(alertController, animated: true, completion: nil)
  }
  
  func groupsTableViewDidTapSwitch(_ sender: GroupsTableViewCell) {
    guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
      try? groupRepository.enable(group: groups[tappedIndexPath.row], isEnabled: sender.activationSwitch.isOn)
  }
}

extension GroupsListController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return groups.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell: GroupsTableViewCell = tableView.dequeueReusableCell(for: indexPath)
    let cellModel = groups[indexPath.row]
    cell.configure(with: cellModel.toViewModel())
    cell.delegate = self
    
    return cell
  }
  
  // MARK: - Editing of tableView
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    onGroupSelect?(groups[(indexPath as NSIndexPath).row])
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
      try? groupRepository.remove(group: groups.remove(at: indexPath.row))
      tableView.deleteRows(at: [indexPath], with: .automatic)
    }
  }
}

class SelectionViewController<T: ListItemType>: UITableViewController {
  
  var items: [T]
  var selectedIndex: Int = 0
  var isMultipleSelect = false
  
  init(items: [T] ) {
    self.items = items
    super.init(nibName: nil, bundle: nil)
//    (nibName: "SelectionViewController", bundle: nil)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

enum Sounds: String {
  case silent
  case loud
  
  static var all: [Sounds] = [.silent, .loud]
}

extension Sounds: ListItemType {
  var name: String {
    switch self {
    case .loud:
      return ""
    default:
      return ""
    }
  }
}

protocol ListItemType {
  var name: String { get }
}
