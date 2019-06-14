final class AuthCoordinator: BaseCoordinator, AuthCoordinatorOutput {
  
  var finishFlow: (() -> Void)?
  
  private let factory: AuthModuleFactory
  private let router: Router
  
  init(router: Router, factory: AuthModuleFactory) {
    self.factory = factory
    self.router = router
  }
  
  override func start() {
    showLogin()
  }
  
  // MARK: - Run current flow's controllers
  
  private func showLogin() {
    let loginOutput = factory.makeLoginOutput()
    loginOutput.onCompleteAuth = { [weak self] in
      self?.finishFlow?()
    }
    loginOutput.onSignUpButtonTap = { [weak self] in
      self?.showSignUp()
    }
    router.setRootModule(loginOutput)
  }
  
  private func showSignUp() {
    let signUpView = factory.makeSignUpHandler()
    signUpView.onCancelButtonTap = { [weak self] in
      self?.router.popModule()
    }
    signUpView.onSignUpComplete = { [weak self] in
      self?.finishFlow?()
    }
    router.push(signUpView)
  }
}
