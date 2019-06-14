protocol GroupsListView: BaseView {
  var onGroupSelect: ((Group) -> Void)? { get set }
  var onCreateGroup: ((Group) -> Void)? { get set }
}
