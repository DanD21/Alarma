//
//  DeepLinkOption.swift
//  Alarma
//
//  Created by Dan Danilescu on 10/24/18.
//  Copyright © 2018 Dan Danilescu. All rights reserved.
//

import Foundation

struct DeepLinkURLConstants {
  static let Onboarding = "onboarding"
  static let Groups = "groups"
  static let Group = "group"
  static let Settings = "settings"
  static let Login = "login"
  static let Terms = "terms"
  static let SignUp = "signUp"
}

enum DeepLinkOption {
  
  case onboarding
  case groups
  case settings
  case login
  case terms
  case signUp
  case group(String?)
  
  static func build(with userActivity: NSUserActivity) -> DeepLinkOption? {
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
      let url = userActivity.webpageURL,
      let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
      // TO DO: extract string and match with DeepLinkURLConstants
      print(components)
    }
    return nil
  }
  
  static func build(with dict: [String: AnyObject]?) -> DeepLinkOption? {
    guard let id = dict?["launch_id"] as? String else { return nil }
    
    let groupID = dict?["group_id"] as? String
    
    switch id {
    case DeepLinkURLConstants.Onboarding: return .onboarding
    case DeepLinkURLConstants.Groups: return .groups
    case DeepLinkURLConstants.Group: return .group(groupID)
    case DeepLinkURLConstants.Settings: return .settings
    case DeepLinkURLConstants.Login: return .login
    case DeepLinkURLConstants.Terms: return .terms
    case DeepLinkURLConstants.SignUp: return .signUp
    default: return nil
    }
  }
}
