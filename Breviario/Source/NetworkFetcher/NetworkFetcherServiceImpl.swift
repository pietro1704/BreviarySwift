//
//  NetworkFetcherServiceImpl.swift
//  Breviario
//
//  Created by Pietro Pugliesi on 29/07/23.
//

import Foundation

struct NetworkFetcherServiceImpl: NetworkFetcherServiceProtocol {

  private let htmlParser = HTMLParser()

  func getHtmlData(liturgicHour: LiturgicHour) async throws -> Data {
    let url = try url(for: liturgicHour)
    return try await getHtmlData(url: url)
  }

  private func getHtmlData(url: URL) async throws -> Data {
    let (data, response) = try await URLSession.shared.data(from: url)
    guard let response = response as? HTTPURLResponse,
          response.statusCode == 200 else {
      throw NetworkErrors.invalidResponse
    }
    return data
  }

  private enum NetworkErrors: Error {
    case invalidResponse
  }

  private func url(for hour: LiturgicHour) throws -> URL {
    let baseUrlString = "http://www.ibreviary.com/m2/breviario.php?b=1"
    let string: String
    switch hour {
    case .oficioLeituras:
      string = "\(baseUrlString)&s=ufficio_delle_letture"
    case .laudes:
      string = "\(baseUrlString)&s=lodi"
    case .horaIntermedia:
      string = "\(baseUrlString)&s=ora_media"
    case .vesperas:
      string = "\(baseUrlString)&s=vespri"
    case .completas:
      string = "\(baseUrlString)&s=compieta"
    case .completasOntem:
      #warning("encontrar url das completas de ontem")
      string = ""
    }
    guard let url = URL(string: string) else {
      throw UrlFromStringErrors.initFromStringFailure
    }
    return url
  }

  private enum UrlFromStringErrors: Error {
    case initFromStringFailure
  }

}
