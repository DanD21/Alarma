//
//  EventKitHelper.swift
//  Alarma
//
//  Created by Dan Danilescu on 2/26/19.
//  Copyright © 2019 Endava. All rights reserved.
//

import Foundation
import EventKit
import SwiftCron

class EventKitHelper {
  
  lazy var eventStore: EKEventStore = setEventStore()
  
  private func setEventStore() -> EKEventStore {
    if eventStore == nil {
      eventStore = EKEventStore()
      
      eventStore.requestAccess(
        to: EKEntityType.reminder, completion: {(granted, error) in
          if !granted {
            print("Access to store not granted")
            print(error?.localizedDescription)
          } else {
            self.eventStore = EKEventStore()
            print("Access granted")
          }
      })
    }
    
    if eventStore != nil {
      self.createReminder(alarm)
    }
    return eventStore
  }
  
  public func setReminder(alarm: Alarm) {
    if eventStore == nil {
      eventStore = EKEventStore()
      
      eventStore.requestAccess(
        to: EKEntityType.reminder, completion: {(granted, error) in
          if !granted {
            print("Access to store not granted")
            print(error?.localizedDescription)
          } else {
            self.eventStore = EKEventStore()
            print("Access granted")
          }
      })
    }
  
    if eventStore != nil {
      self.createReminder(alarm)
    }
  }

  func createReminder(_ alarm: Alarm) {
    let reminder = EKReminder(eventStore: eventStore)
    
    reminder.title = ("[Alarma] \(alarm.groupName)")
    reminder.calendar = eventStore.defaultCalendarForNewReminders()
    let alarmDate = alarm.time
    let cron = toCron(alarmDate)
    
    let oneYear: TimeInterval = 365 * 24 * 60 * 60
    let oneYearFromNow = alarmDate.addingTimeInterval(oneYear)
    let recurringEnd = EKRecurrenceEnd(end: oneYearFromNow)
    
    
    let recurringRule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.daily,
                                         interval: 1,
                                         end: recurringEnd)
    reminder.recurrenceRules = [recurringRule]
    
    let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: alarmDate)
    reminder.dueDateComponents = dateComponents
    let ekAlarm = EKAlarm(absoluteDate: alarmDate)
    
    reminder.addAlarm(ekAlarm)
    
    do {
      try eventStore.save(reminder, commit: true)
    } catch let error {
      print("Reminder failed with error \(error.localizedDescription)")
    }
  }
  
  func toCron(_ date: Date) {
    
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.day, .hour, .minute], from: date)
    
    guard let minute = dateComponents.minute,
      let hour = dateComponents.hour,
      let day = dateComponents.day else { return }
    let cronExpression = CronExpression(minute: minute,
                                        hour: hour,
                                        day: day)
  }
}
