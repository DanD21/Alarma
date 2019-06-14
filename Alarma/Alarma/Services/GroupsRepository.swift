//
//  GroupsRepository.swift
//  Alarma
//
//  Created by Dan Danilescu on 12/18/18.
//  Copyright © 2018 Endava. All rights reserved.
//

import Foundation
import RealmSwift

class GroupRepositoryImp: GroupRepository {
  
  lazy var realm = try! Realm()
  var alarmRepository: AlarmRepository = AlarmRepositoryImp()
  
  func fetchAllGroups() -> [Group] {
    let groups = realm.objects(RealmGroup.self)
    return groups.map({ $0.toModel() })
  }
  
  func save(group: Group) throws -> RealmGroup {
    let newGroup = group.toRealmEntity()
    try realm.write {
      realm.add(newGroup, update: true)
    }
    return newGroup
  }
  
  func remove(group: Group) throws {
    try realm.write {
      guard let group = realm.object(ofType: RealmGroup.self, forPrimaryKey: group.groupID)
        else { return }
      let alarms = realm.objects(RealmAlarm.self).filter("groupID = %@", group.groupID)
      realm.delete(group)
      realm.delete(alarms)
    }
  }
  
  func update(alarm: Alarm, id: String) throws {
    try realm.write {
      let group = realm.object(ofType: RealmGroup.self, forPrimaryKey: id)
      group?.alarmList.append(alarm.toRealmEntity())
      let sorted = group?.alarmList.sorted(byKeyPath: "time")
    }
  }
  
  func enable(group: Group, isEnabled: Bool) throws {
    try realm.write {
      let group = realm.object(ofType: RealmGroup.self, forPrimaryKey: group.groupID)
      group?.isEnabled = isEnabled
    }
  }
}
