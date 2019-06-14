//
//  Repository.swift
//  Alarma
//
//  Created by Dan Danilescu on 12/18/18.
//  Copyright © 2018 Endava. All rights reserved.
//

import Foundation

//protocol Repository {
//
//  associatedtype T
//
//  func getAll() -> [T]
//  func get(identifier: Int) -> T?
//  func create(a: T) -> Bool
//  func update(a: T) -> Bool
//  func delete(a: T) -> Bool
//}

protocol GroupRepository {
  func fetchAllGroups() -> [Group]
  func remove(group: Group) throws
  func save(group: Group) throws -> RealmGroup
  func update(alarm: Alarm, id: String) throws
  func enable(group: Group, isEnabled: Bool) throws
}

protocol AlarmRepository {
  func fetchAllAlarms(group: Group) -> [Alarm]
  func remove(alarm: Alarm) throws
  func save(alarm: Alarm) throws
  func enable(alarm: Alarm, isEnabled: Bool) throws
}
