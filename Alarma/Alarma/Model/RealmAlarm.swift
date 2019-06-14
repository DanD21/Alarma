//
//  Alarm.swift
//  Alarma
//
//  Created by Dan Danilescu on 11/1/18.
//  Copyright © 2018 Endava. All rights reserved.
//

import RealmSwift

@objcMembers
class RealmAlarm: Object {
  
  dynamic var alarmID = ""
  dynamic var groupID = ""
  dynamic var groupName = ""
  dynamic var time = Date()
  dynamic var isEnabled = true
  dynamic var sound = ""
  dynamic var loopSound = true
  
  var repeatDays = List<Int>()
  
  override static func primaryKey() -> String? {
    return "alarmID"
  }
  
  convenience init(alarmID: String,
                   groupID: String,
                   groupName: String,
                   time: Date,
                   isEnabled: Bool,
                   sound: String,
                   loopSound: Bool,
                   repeatDays: [Weekdays]) {
    self.init()
    self.alarmID = UUID().uuidString
    self.groupID = groupID
    self.groupName = groupName
    self.time = time
    self.isEnabled = isEnabled
    self.sound = sound
    self.loopSound = loopSound
    
    self.repeatDays.removeAll()
    repeatDays.forEach { weekday in
      self.repeatDays.append(weekday.rawValue)
    }
  }

  func toModel() -> Alarm {
    return Alarm(alarmID: alarmID,
                 groupID: groupID,
                 groupName: groupName,
                 time: time,
                 isEnabled: isEnabled,
                 sound: sound,
                 loopSound: loopSound,
                 repeatDays: repeatDays.map({ Weekdays(rawValue: $0)! }))
  }
}

struct Alarm {
  var alarmID = ""
  var groupID = ""
  var groupName = ""
  var time = Date()
  var isEnabled = true
  var sound = ""
  var loopSound = true
  var repeatDays = [Weekdays]()
  
  init(alarmID: String = "",
       groupID: String = "",
       groupName: String,
       time: Date = Date(),
       isEnabled: Bool = false,
       sound: String = "",
       loopSound: Bool = false,
       repeatDays: [Weekdays] = []) {
    self.alarmID = alarmID
    self.groupID = groupID
    self.groupName = groupName
    self.time = time
    self.isEnabled = isEnabled
    self.sound = sound
    self.loopSound = loopSound
    self.repeatDays = repeatDays
    }
  
  func toViewModel() -> AlarmViewModel {
    return AlarmViewModel(alarmID: alarmID,
                          groupID: groupID,
                          groupName: groupName,
                          time: time,
                          isEnabled: isEnabled,
                          sound: sound)
  }
}

struct AlarmViewModel {
  var alarmID: String
  var groupID: String
  var groupName: String
  var time: Date
  var isEnabled: Bool
  var sound: String
}

enum Weekdays: Int {
  case never = 0
  case monday = 1
  case tuesday = 2
  case wednesday = 3
  case thursday = 4
  case friday = 5
  case saturday = 6
  case sunday = 7
}
