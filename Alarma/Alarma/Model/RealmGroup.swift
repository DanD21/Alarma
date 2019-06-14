import Foundation
import RealmSwift

@objcMembers
class RealmGroup: Object {
  dynamic var groupID = ""
  dynamic var groupName = "New"
  dynamic var interval = ""
  dynamic var isEnabled = true
  let alarmList = List<RealmAlarm>()
  
  override static func primaryKey() -> String? {
    return "groupID"
  }
  
  convenience init(groupID: String,
                   groupName: String,
                   interval: String,
                   isEnabled: Bool,
                   alarmList: [Alarm]) {
    self.init()
    
    self.groupID = UUID().uuidString
    self.groupName = groupName
    self.interval = interval
    self.isEnabled = isEnabled
    
    self.alarmList.removeAll()
    alarmList.forEach { alarm in
      self.alarmList.append(alarm.toRealmEntity())
    }
  }
  
  func toModel() -> Group {
    return Group(groupID: groupID,
                 groupName: groupName,
                 interval: interval,
                 isEnabled: isEnabled,
                 alarmList: alarmList.map({ $0.toModel() }))
  }
}

struct Group {
  var groupID: String
  var groupName: String
  var interval: String
  var isEnabled: Bool = false
  var alarmList: [Alarm] = [Alarm]()
  
  init(groupID: String = "",
       groupName: String,
       interval: String = "",
       isEnabled: Bool = false,
       alarmList: [Alarm] = []) {
    self.groupID = groupID
    self.groupName = groupName
    self.interval = interval
    self.isEnabled = isEnabled
    self.alarmList = alarmList
  }
  
  func toViewModel() -> GroupViewModel {
    return GroupViewModel(groupID: groupID,
                          groupName: groupName,
                          interval: interval,
                          isEnabled: isEnabled)
  }
}

struct GroupViewModel {
  var groupID: String
  var groupName: String
  var interval: String
  var isEnabled: Bool
}
