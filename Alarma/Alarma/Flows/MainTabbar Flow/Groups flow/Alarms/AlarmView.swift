//
//  AlarmView.swift
//  Alarma
//
//  Created by Dan Danilescu on 11/6/18.
//  Copyright © 2018 Endava. All rights reserved.
//

protocol AlarmView: BaseView {
  var onAlarmCreated: ((Alarm) -> Void)? { get set }
}
