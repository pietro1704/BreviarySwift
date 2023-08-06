//
//  DateHourLiturgicHourClassifierService.swift
//  Breviario
//
//  Created by Pietro Pugliesi on 29/07/23.
//

import Foundation

struct DateHourLiturgicHourClassifierService {

  private let hourProvider: HourProviderProtocol

  init(hourProvider: HourProviderProtocol = HourProviderImpl()) {
    self.hourProvider = hourProvider
  }

  func getCurrentDateHour() -> Int {
    let currentDate = hourProvider.currentDate
    let hour = Calendar.current.component(.hour, from: currentDate)
    return hour
  }

  func getRecommendedLiturgicHour() -> LiturgicHour {
    let dateHour = getCurrentDateHour()
    if 0 <= dateHour, dateHour < 3 {
      return .completasOntem
    }
    if 3 <= dateHour, dateHour < 6 {
      return .oficioLeituras
    }
    if 6 <= dateHour, dateHour < 9 {
      return .laudes
    }
    if 9 <= dateHour, dateHour < 17 {
      return .horaIntermedia
    }
    if 17 <= dateHour, dateHour < 21 {
      return .vesperas
    }
    if 21 <= dateHour, dateHour <= 23 {
      return .completas
    }
    return .oficioLeituras
  }

}
