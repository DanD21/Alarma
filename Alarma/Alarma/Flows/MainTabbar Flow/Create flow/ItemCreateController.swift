//
//  GroupCreateController.swift
//  Alarma
//
//  Created by Dan Danilescu on 10/24/18.
//  Copyright © 2018 Dan Danilescu. All rights reserved.
//

import UIKit

final class GroupCreateController: UIViewController, GroupCreateView {
  
  //controller handler
  var onHideButtonTap: (() -> Void)?
  var onCompleteCreateGroup: ((Group) -> Void)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Create"
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Hide", style: .plain, target: self, action: #selector(hideButtonClicked(_:)))
  }
  
  @IBAction func hideButtonClicked(_ sender: UIBarButtonItem) {
    onHideButtonTap?()
  }
  
  @IBAction func createButtonClicked(_ sender: UIBarButtonItem) {
//    onCompleteCreateGroup?(RealmGroup(groupName: "groupName", time: "", isEnabled: true))
  }
}
