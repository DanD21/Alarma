protocol SignUpView: BaseView {
  
  var onSignUpComplete: (() -> Void)? { get set }
  var onCancelButtonTap: (() -> Void)? { get set }
}
