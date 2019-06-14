protocol GroupModuleFactory {
  func makeGroupsOutput() -> GroupsListView
  func makeGroupDetailOutput(group: Group) -> GroupDetailView
  func makeAlarmOutput(group: Group) -> AlarmView
}
