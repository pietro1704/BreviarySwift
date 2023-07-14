//
//  ContentView.swift
//  Breviario
//
//  Created by Pietro Pugliesi on 12/07/23.
//

import SwiftUI

struct ContentView: View {

  @State private var hourText: String?

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
            hourText = "Erro!\(error)"
          }
        }
      }
    }
    .statusBar(hidden: true)
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
    let string: String
    switch hour {
    case .OficioLeituras:
      string = "http://www.ibreviary.com/m2/breviario.php?s=ufficio_delle_letture"
    case .Laudes:
      string = "http://www.ibreviary.com/m2/breviario.php?s=lodi"
    case .HoraIntermedia:
      string = "http://www.ibreviary.com/m2/breviario.php?s=ora_media"
    case .Vesperas:
      string = "http://www.ibreviary.com/m2/breviario.php?s=vespri"
    case .Completas:
      string = "http://www.ibreviary.com/m2/breviario.php?s=compieta"
    }

    if let url = URL(string: string) {
      return url
    } else {
      throw URLErrors.invalidURL
    }
  }

  func getText(hour: LiturgicHoursManager.LiturgicHour) async throws -> String {
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
    case OficioLeituras = "Ofício das Leituras"
    case Laudes = "Laudes"
    case HoraIntermedia = "Hora Intermediária"
    case Vesperas = "Vésperas"
    case Completas = "Completas"
  }

  static let shared = LiturgicHoursManager()
  private let dateFormatter = DateFormatter()

  private init() { }

  func getRecommendedHourText() async throws -> String {
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
      return .OficioLeituras
    }
    if 6 <= currentHour, currentHour < 9 {
      return .Laudes
    }
    if 9 <= currentHour, currentHour < 18 {
      return .HoraIntermedia
    }
    if 18 <= currentHour, currentHour < 21 {
      return .Vesperas
    }
    if 21 <= currentHour, currentHour <= 23 {
      return .Completas
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

  func parse(_ htmlString: String) throws -> String {
    guard let data = htmlString.data(using: .utf8) else {
      throw ParseErrors.invalidHTMLData
    }
    let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
      .documentType: NSAttributedString.DocumentType.html,
      .characterEncoding: String.Encoding.utf8.rawValue
    ]
    guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
      throw ParseErrors.conversionFailure
    }
    return attributedString.string
  }
}