import RealmSwift

final class GroupCoordinator: BaseCoordinator {
  
  private let factory: GroupModuleFactory
  private let coordinatorFactory: CoordinatorFactory
  private let router: Router
  
  var selectedGroup: Group?
  let repository: GroupRepository = GroupRepositoryImp()
  let eventKit = EventKitHelper()
  
  init(router: Router, factory: GroupModuleFactory, coordinatorFactory: CoordinatorFactory) {
    self.router = router
    self.factory = factory
    self.coordinatorFactory = coordinatorFactory
  }
  
  override func start() {
    showRealmGroup()
  }
  
  // MARK: - Run current flow's controllers
  
  private func showRealmGroup() {
    
    let groupsOutput = factory.makeGroupsOutput()
    groupsOutput.onGroupSelect = { [weak self] (group) in
      self?.selectedGroup = group
      self?.showGroupDetail(group)
    }
    
    groupsOutput.onCreateGroup = { [weak self] (group) in
      self?.selectedGroup = group
      self?.runCreationFlow(group)
      self?.showGroupDetail(group)
    }
    router.setRootModule(groupsOutput)
  }
  
  private func showGroupDetail(_ group: Group) {
    
    let groupDetailFlowOutput = factory.makeGroupDetailOutput(group: group)
    groupDetailFlowOutput.onCreateAlarmButtonTapped = { [weak self] group in
      self?.showAlarmCreation(group)
    }
    router.push(groupDetailFlowOutput)
  }
  
  private func showAlarmCreation(_ group: Group) {
    let alarmCreationView = factory.makeAlarmOutput(group: group)
    
    alarmCreationView.onAlarmCreated = { [unowned self] alarm in
      
      guard let groupID = self.selectedGroup?.groupID else { return }
      guard let alarms = self.selectedGroup?.alarmList else { return }

      try? self.repository.update(alarm: alarm, id: groupID)
      self.eventKit.setReminder(alarm: alarm)
      self.router.popModule()
    }
    router.push(alarmCreationView, animated: true, completion: nil)
  }
  
  // MARK: - Run coordinators (switch to another flow)

  private func runCreationFlow(_ group: Group) {
    
    let (coordinator, module) = coordinatorFactory.makeGroupCreationCoordinatorBox()
    coordinator.finishFlow = { [weak self, weak coordinator] group in
      
      self?.router.dismissModule()
      self?.removeDependency(coordinator)
      if let group = group {
        self?.showGroupDetail(group)
      }
    }
    addDependency(coordinator)
    
    router.present(module)
    coordinator.start()
  }
}
