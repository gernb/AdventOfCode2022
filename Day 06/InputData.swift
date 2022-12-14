//
//  InputData.swift
//  Day 06
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

import Foundation

enum InputData: String, CaseIterable {
    case example1, example2, example3, example4, example5
    case challenge

    var data: [String] {
        switch self {

        case .example1: return "mjqjpqmgbljsphdztnvjfqwrcgsmlb".map(String.init)    // 7
        case .example2: return "bvwbjplbgvbhsrlpgdmjqwftvncz".map(String.init)      // 5
        case .example3: return "nppdvjthqldpwncqszvftbrmjlhg".map(String.init)      // 6
        case .example4: return "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg".map(String.init) // 10
        case .example5: return "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw".map(String.init)  // 11

        case .challenge:
            return try! String(contentsOfFile: ("~/Desktop/input.txt" as NSString).expandingTildeInPath)
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .map(String.init)

        }
    }
}
