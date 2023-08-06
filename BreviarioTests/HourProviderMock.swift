//
//  HourProviderMock.swift
//  BreviarioTests
//
//  Created by Pietro Pugliesi on 05/08/23.
//

import Foundation

struct HourProviderMock: HourProviderProtocol {

  private let currentSavedDate: Date

  init(currentDate: Date) {
    currentSavedDate = currentDate
  }

  var currentDate: Date {
    currentSavedDate
  }

}
