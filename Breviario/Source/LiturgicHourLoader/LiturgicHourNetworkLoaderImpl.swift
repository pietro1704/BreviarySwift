//
//  LiturgicHourNetworkLoaderImpl.swift
//  Breviario
//
//  Created by Pietro Pugliesi on 05/08/23.
//

import Foundation

struct LiturgicHourNetworkLoaderServiceImpl: LiturgicHourNetworkLoaderServiceProtocol {

  private let parser = HTMLParser()
  private let networkFetcher: NetworkFetcherServiceProtocol

  init(networkFetcher: NetworkFetcherServiceProtocol = NetworkFetcherServiceImpl()) {
    self.networkFetcher = networkFetcher
  }

  func loadLiturgicHourText(hour: LiturgicHour) async throws -> String {
    let data = try await networkFetcher.getHtmlData(liturgicHour: hour)
    let text = try parser.parse(data)
    #warning("create LitTextStruct, with separated strings and styling for each part, to parse, and separate later")
    return "\(text)"
  }

}
