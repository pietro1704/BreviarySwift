//
//  LiturgicHourViewModel.swift
//  Breviario
//
//  Created by Pietro Pugliesi on 03/08/23.
//

import Foundation

final class LiturgicHourViewModel: ObservableObject {

  // MARK: - Public Properties

  var currentHourText: String {
    "\(hourClassifier.getCurrentDateHour())"
  }
  
  // MARK: - Private Properties

  @Published
  private(set) var liturgicHourText: String?

  @Published
  private(set) var isError: Bool

  private let liturgicHourNetworkLoaderService: LiturgicHourNetworkLoaderServiceProtocol
  private let hourClassifier: DateHourLiturgicHourClassifierService

  // MARK: - Init

  init(liturgicHourNetworkLoaderService: LiturgicHourNetworkLoaderServiceProtocol = LiturgicHourNetworkLoaderServiceImpl(),
       hourClassifier: DateHourLiturgicHourClassifierService = .init()) {
    self.liturgicHourNetworkLoaderService = liturgicHourNetworkLoaderService
    self.hourClassifier = hourClassifier
    isError = false
  }

  // MARK: - Public Methods

  func loadRecommendedHourText() async {
    let recommendedHour = hourClassifier.getRecommendedLiturgicHour()
    do {
      liturgicHourText = try await liturgicHourNetworkLoaderService.loadLiturgicHourText(hour: recommendedHour)
    } catch {
      isError = true
    }
  }

}
