//
//  NetworkFetcherServiceProtocol.swift
//  Breviario
//
//  Created by Pietro Pugliesi on 03/08/23.
//

import Foundation

protocol NetworkFetcherServiceProtocol {

  func getHtmlData(liturgicHour: LiturgicHour) async throws -> Data
  
}
