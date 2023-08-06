//
//  LiturgicHourNetworkLoaderServiceProtocol.swift
//  Breviario
//
//  Created by Pietro Pugliesi on 05/08/23.
//

import Foundation

protocol LiturgicHourNetworkLoaderServiceProtocol {

  func loadLiturgicHourText(hour: LiturgicHour) async throws -> String

}
