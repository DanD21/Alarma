//
//  NotificationsDeniedView.swift
//  Alarma
//
//  Created by Dan Danilescu on 10/24/18.
//  Copyright © 2018 Dan Danilescu. All rights reserved.
//

protocol NotificationsDeniedView: BaseView {
  var onPermissionsGranted: (() -> Void)? { get set }
}
