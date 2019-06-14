//
//  AlarmsRepository.swift
//  Alarma
//
//  Created by Dan Danilescu on 2/4/19.
//  Copyright © 2019 Endava. All rights reserved.
//

import Foundation
import RealmSwift

class AlarmRepositoryImp: AlarmRepository {
  
  var realm = try! Realm()
  
  func fetchAllAlarms(group: Group) -> [Alarm] {
    let alarms = realm.objects(RealmAlarm.self).filter("groupID = %@", group.groupID)
    return alarms.map({
      $0.toModel()
    })
  }
  
  func save(alarm: Alarm) throws {
    try realm.write {
      realm.add(alarm.toRealmEntity())
    }
  }
  
  func enable(alarm: Alarm, isEnabled: Bool) throws {
    try realm.write {
      let alarm = realm.object(ofType: RealmAlarm.self, forPrimaryKey: alarm.alarmID)
      alarm?.isEnabled = isEnabled
    }
  }
  
  func remove(alarm: Alarm) throws {
    try realm.write {
      guard let alarm = realm.object(ofType: RealmAlarm.self, forPrimaryKey: alarm.alarmID)
        else { return }
      realm.delete(alarm)
    }
  }  
}
