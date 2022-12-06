//
//  main.swift
//  Day 06
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

// MARK: - Part 1

print("Day 06:")

enum Part1 {
    static func run(_ source: InputData) {
        let input = source.data

        for index in 3 ..< input.count {
            let slice = Set(input[(index - 3) ... index])
            if slice.count == 4 {
                print("Part 1 (\(source)): \(index + 1)")
                return
            }
        }
    }
}

InputData.allCases.forEach(Part1.run)

// MARK: - Part 2

print("")

enum Part2 {
    static func run(_ source: InputData) {
        let input = source.data

        print("Part 2 (\(source)):")
    }
}

InputData.allCases.forEach(Part2.run)
