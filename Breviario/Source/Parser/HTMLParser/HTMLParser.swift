//
//  HTMLParser.swift
//  Breviario
//
//  Created by Pietro Pugliesi on 29/07/23.
//

import Foundation

struct HTMLParser {

  private enum ParseErrors: Error {
    case conversionToStringFailure
  }

  func parse(_ data: Data) throws -> AttributedString {
    do {
      let attributedString = try NSAttributedString(
        data: data,
        options: [
          .documentType: NSAttributedString.DocumentType.html
        ],
        documentAttributes: nil)
      return .init(attributedString)
    } catch let error {
      throw ParseErrors.conversionToStringFailure
    }
  }

}
