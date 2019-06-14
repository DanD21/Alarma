protocol GroupDetailView: BaseView {
  var onCreateAlarmButtonTapped: ((Group) -> Void)? { get set }
//  var onBackButtonTapped: (() -> Void)? { get set }
  
}
