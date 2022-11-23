//
//  InputData.swift
//  Day 18
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

import Foundation

enum InputData: String, CaseIterable {
    case example, challenge

    var data: [String] {
        switch self {

        case .example: return """
""".components(separatedBy: .newlines)

        case .challenge: return """
""".components(separatedBy: .newlines)

        }
    }
}
