//
//  main.swift
//  Day 04
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

typealias Assignment = ClosedRange<Int>

extension Assignment {
    init(string: String) {
        let ends = string.components(separatedBy: "-").compactMap(Int.init)
        self = ends[0] ... ends [1]
    }
}

struct Cleanup {
    let elf1: Assignment
    let elf2: Assignment

    var fullyOverlaps: Bool {
        (elf1.contains(elf2.lowerBound) && elf1.contains(elf2.upperBound)) ||
         (elf2.contains(elf1.lowerBound) && elf2.contains(elf1.upperBound))
    }

    init(line: String) {
        let parts = line.components(separatedBy: ",")
        self.elf1 = .init(string: parts[0])
        self.elf2 = .init(string: parts[1])
    }
}

// MARK: - Part 1

print("Day 04:")

enum Part1 {
    static func run(_ source: InputData) {
        let input = source.data
        let pairs = input.map(Cleanup.init(line:))
        let count = pairs.filter(\.fullyOverlaps).count

        print("Part 1 (\(source)): \(count)")
    }
}

InputData.allCases.forEach(Part1.run)

// MARK: - Part 2

print("")

enum Part2 {
    static func run(_ source: InputData) {
        let input = source.data
        let pairs = input.map(Cleanup.init(line:))
        let count = pairs.filter({ $0.elf1.overlaps($0.elf2) }).count

        print("Part 2 (\(source)): \(count)")
    }
}

InputData.allCases.forEach(Part2.run)
