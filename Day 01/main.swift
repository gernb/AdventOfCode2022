//
//  main.swift
//  Day 01
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

// MARK: - Part 1

print("Day 01:")

struct Elf {
    var items: [Int] = []

    var totalCalories: Int {
        items.reduce(0, +)
    }

    static func elves(from input: [String]) -> [Elf] {
        var elves: [Elf] = []

        var elf = Elf()
        for line in input {
            if line.isEmpty {
                elves.append(elf)
                elf = Elf()
                continue
            }
            if let item = Int(line) {
                elf.items.append(item)
            }
        }
        if elf.items.isEmpty == false {
            elves.append(elf)
        }

        return elves
    }
}

enum Part1 {
    static func run(_ source: InputData) {
        let input = source.data
        let elves = Elf.elves(from: input)

        let maxCalories = elves.max(by: { $0.totalCalories < $1.totalCalories })!.totalCalories

        print("Part 1 (\(source)): \(maxCalories)")
    }
}

InputData.allCases.forEach(Part1.run)

// MARK: - Part 2

print("")

enum Part2 {
    static func run(_ source: InputData) {
        let input = source.data
        let elves = Elf.elves(from: input)

        let topThree = elves.sorted(by: { $0.totalCalories > $1.totalCalories }).prefix(3)
        let total = topThree.map(\.totalCalories).reduce(0, +)

        print("Part 2 (\(source)): \(total)")
    }
}

InputData.allCases.forEach(Part2.run)
