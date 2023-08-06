//
//  LiturgicHourNetworkLoaderServiceMock.swift
//  Breviario
//
//  Created by Pietro Pugliesi on 05/08/23.
//

import Foundation

struct LiturgicHourNetworkLoaderServiceMock: LiturgicHourNetworkLoaderServiceProtocol {

  var mockSuccessText: String

  func loadLiturgicHourText(hour: LiturgicHour) -> String {
    return mockSuccessText
  }

}
