final class GroupCreateCoordinator: BaseCoordinator, GroupCreateCoordinatorOutput {
  
  var finishFlow: ((Group?) -> Void)?
  
  private let factory: GroupCreateModuleFactory
  private let router: Router
  
  init(router: Router, factory: GroupCreateModuleFactory) {
    self.factory = factory
    self.router = router
  }
  
  override func start() {
    showCreate()
  }
  
  // MARK: - Run current flow's controllers
  
  private func showCreate() {
    let createGroupOutput = factory.makeGroupAddOutput()
    createGroupOutput.onCompleteCreateGroup = { [weak self] group in
      self?.finishFlow?(group)
    }
    createGroupOutput.onHideButtonTap = { [weak self] in
      self?.finishFlow?(nil)
    }
    router.setRootModule(createGroupOutput)
  }
}
