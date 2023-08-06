//
//  DateHourLiturgicHourClassifierServiceTests.swift
//  BreviarioTests
//
//  Created by Pietro Pugliesi on 03/08/23.
//

import XCTest

final class DateHourLiturgicHourClassifierServiceTests: XCTestCase {

  private var sut: DateHourLiturgicHourClassifierService!

  override func tearDown() {
    sut = nil
  }

  func test_GetCurrentDateHour_GivenValidDateWithHour_ExpectCorrectHour() {
    // Given
    let date = DateComponents(calendar: .current, hour: 4, minute: 5, second: 57).date!
    let provider = HourProviderMock(currentDate: date)
    sut = .init(hourProvider: provider)
    // When
    let result = sut.getCurrentDateHour()
    // Assert
    XCTAssertEqual(result, 4)
  }

  #warning("add outros testes de borda (data sem hora, hora >24, etc")
}
