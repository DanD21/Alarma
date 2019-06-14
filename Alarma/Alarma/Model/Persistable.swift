//
//  Persistable.swift
//  Alarma
//
//  Created by Dan Danilescu on 1/22/19.
//  Copyright © 2019 Endava. All rights reserved.
//

import RealmSwift

protocol Persistable {
  associatedtype T: Object
  func toRealmEntity() -> T
}

protocol RealmConvertable {
  associatedtype T
  func toStruct() -> T
}

extension Group: Persistable {
  func toRealmEntity() -> RealmGroup {
    return RealmGroup(groupID: groupID,
                      groupName: groupName,
                      interval: interval,
                      isEnabled: isEnabled,
                      alarmList: alarmList)
  }
}

extension Alarm: Persistable {
  func toRealmEntity() -> RealmAlarm {
    return RealmAlarm(alarmID: alarmID,
                      groupID: groupID,
                      groupName: groupName,
                      time: time,
                      isEnabled: isEnabled,
                      sound: sound,
                      loopSound: loopSound,
                      repeatDays: repeatDays)
  }
}
