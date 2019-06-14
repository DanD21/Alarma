protocol GroupCreateView: BaseView {
  var onHideButtonTap: (() -> Void)? { get set }
  var onCompleteCreateGroup: ((Group) -> Void)? { get set }
}
