//
//  LiturgicHourView.swift
//  Breviario
//
//  Created by Pietro Pugliesi on 12/07/23.
//

import SwiftUI

struct LiturgicHourView: View {

  // MARK: - Private Properties

  @ObservedObject
  private var viewModel: LiturgicHourViewModel = .init()

  // MARK: - Init

  init(viewModel: LiturgicHourViewModel = .init()) {
    self.viewModel = viewModel
  }

  // MARK: - View Body

  var body: some View {
    List {
      VStack {
        Text("são \(viewModel.currentHourText) horas.")
        if let hourText = viewModel.liturgicHourText {
          Text(hourText)
            .font(.system(size: UIFontMetrics.default.scaledValue(for: UIFont.systemFontSize)))
        } else {
          ProgressView()
        }
      }
      .task {
        await viewModel.loadRecommendedHourText()
      }
    }
    .listStyle(.plain)
    .listSectionSeparator(.hidden)
    .refreshable {
      await viewModel.loadRecommendedHourText()
    }

    #if os(iOS)
      .statusBar(hidden: true)
    #endif
  }

}

// MARK: - Preview

struct Provider: PreviewProvider {

  static var previews: some View {
    let service = LiturgicHourNetworkLoaderServiceMock(mockSuccessText: "teste")
    let viewModel = LiturgicHourViewModel(liturgicHourNetworkLoaderService: service)
    return LiturgicHourView()
  }

}
