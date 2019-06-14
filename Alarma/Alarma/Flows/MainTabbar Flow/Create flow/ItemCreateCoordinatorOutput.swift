protocol GroupCreateCoordinatorOutput: class {
  var finishFlow: ((Group?) -> Void)? { get set }
}
