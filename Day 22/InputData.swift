//
//  InputData.swift
//  Day 22
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

import Foundation

enum InputData: String, CaseIterable {
    static let day = 22

    case example, challenge

    var map: [String] { self.lines.dropLast(2) }
    var path: String { self.lines.last! }

    var lines: [String] {
        switch self {

        case .example: return """
        ...#
        .#..
        #...
        ....
...#.......#
........#...
..#....#....
..........#.
        ...#....
        .....#..
        .#......
        ......#.

10R5L5R10L4R5L5
""".components(separatedBy: .newlines)

        case .challenge:
            return try! String(contentsOfFile: ("~/Desktop/input.txt" as NSString).expandingTildeInPath)
                .trimmingCharacters(in: .newlines)
                .components(separatedBy: .newlines)

        }
    }
}
