//
//  ContentView.swift
//  Breviario
//
//  Created by Pietro Pugliesi on 12/07/23.
//

import SwiftUI

struct ContentView: View {

  @State private var hourText: AttributedString?

  private var currentHour: Int {
    LiturgicHoursManager.shared.currentDateHour()
  }
  private var recommendedHourString: String {
    LiturgicHoursManager.shared.recommendedLiturgicHour(for: currentHour)?.rawValue ?? "Nao ha hora liturgica recomendada para hora \(currentHour)"
  }

  var body: some View {
    ScrollView {
      VStack {
        Text("são \(currentHour) horas.")
        Text(recommendedHourString)
        Group {
          if let hourText {
            Text(hourText)
          } else {
            ProgressView()
          }
        }
        .task {
          do {
            hourText = try await LiturgicHoursManager.shared.getRecommendedHourText()
          } catch let error {
            hourText = .init(stringLiteral: "Erro!\(error)")
          }
        }
      }
      .padding(.all)
    }
    #if os(iOS)
      .statusBar(hidden: true)
    #endif
  }

}

struct ContentView_Previews: PreviewProvider {

  static var previews: some View {
    ContentView()
  }

}

final class NetworkManager {

  enum NetworkErrors: Error {
    case invalidResponse
  }

  private enum URLErrors: Error {
    case invalidURL
  }

  static let shared = NetworkManager()

  private init() {}

  private func url(for hour: LiturgicHoursManager.LiturgicHour) throws -> URL {
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
    }
    guard let url = URL(string: string) else {
      throw HTMLParser.ParseErrors.conversionFailure
    }
    return url
  }

  @MainActor
  func getText(hour: LiturgicHoursManager.LiturgicHour) async throws -> AttributedString {
    let (data, response) = try await URLSession.shared.data(from: url(for: hour))
    guard let response = response as? HTTPURLResponse,
          response.statusCode == 200 else {
      throw NetworkErrors.invalidResponse
    }

    do {
      guard let htmlString = String(data: data, encoding: .utf8) else {
        throw HTMLParser.ParseErrors.invalidHTMLData
      }
      let string = try HTMLParser.shared.parse(htmlString)
      return string
    } catch {
      throw HTMLParser.ParseErrors.conversionFailure
    }
  }

}


final class LiturgicHoursManager {

  enum LiturgicHour: String {
    case oficioLeituras = "Ofício das Leituras"
    case laudes = "Laudes"
    case horaIntermedia = "Hora Intermediária"
    case vesperas = "Vésperas"
    case completas = "Completas"
  }

  static let shared = LiturgicHoursManager()
  private let dateFormatter = DateFormatter()

  private init() {}

  @MainActor
  func getRecommendedHourText() async throws -> AttributedString {
    let recommendedLiturgicHour = recommendedLiturgicHour(for: currentDateHour())!
    do {
      return try await NetworkManager.shared.getText(hour: recommendedLiturgicHour)
    } catch let error {
      throw error
    }
  }

  func currentDateHour() -> Int {
    let nowDate = Date()
    let hour = Calendar.current.component(.hour, from: nowDate)
    return hour
  }

  func recommendedLiturgicHour(for currentHour: Int) -> LiturgicHour? {
    if 0 <= currentHour, currentHour < 6 {
      return .oficioLeituras
    }
    if 6 <= currentHour, currentHour < 9 {
      return .laudes
    }
    if 9 <= currentHour, currentHour < 18 {
      return .horaIntermedia
    }
    if 18 <= currentHour, currentHour < 21 {
      return .vesperas
    }
    if 21 <= currentHour, currentHour <= 23 {
      return .completas
    }
    return nil
  }

}

final class HTMLParser {

  static let shared = HTMLParser()
  private init() {}

  enum ParseErrors: Error {
    case invalidHTMLData
    case conversionFailure
  }

  @MainActor
  func parse(_ htmlString: String) throws -> AttributedString {
    guard let data = htmlString.data(using: .utf8) else {
      throw ParseErrors.invalidHTMLData
    }
    guard let attributedString = try? NSAttributedString(
      data: data,
      options: [
        .documentType: NSAttributedString.DocumentType.html
      ],
      documentAttributes: nil) else {
      throw ParseErrors.conversionFailure
    }
    return .init(attributedString)
  }

}
