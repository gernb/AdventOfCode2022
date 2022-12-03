//
//  main.swift
//  Day 03
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

struct Rucksack {
    typealias ItemType = Character
    typealias Compartment = [ItemType]

    let compartments: [Compartment]

    var commonItem: ItemType {
        let one = Set(compartments[0])
        let two = Set(compartments[1])
        return one.intersection(two).first!
    }

    init(line: String) {
        let length = line.count
        let compartment1: Compartment = Array(line.prefix(length / 2))
        let compartment2: Compartment = Array(line.suffix(length / 2))
        self.compartments = [compartment1, compartment2]
    }
}

extension Rucksack.ItemType {
    var priority: Int {
        if self.isLowercase {
            let value = self.asciiValue! - Character("a").asciiValue! + 1
            return Int(value)
        } else {
            let value = self.asciiValue! - Character("A").asciiValue! + 27
            return Int(value)
        }
    }
}

// MARK: - Part 1

print("Day 03:")

enum Part1 {
    static func run(_ source: InputData) {
        let input = source.data
        let sacks = input.map(Rucksack.init(line:))
        let total = sacks.map(\.commonItem.priority).reduce(0, +)

        print("Part 1 (\(source)): \(total)")
    }
}

InputData.allCases.forEach(Part1.run)

// MARK: - Part 2

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension Rucksack {
    var itemSet: Set<ItemType> {
        Set(compartments[0]).union(Set(compartments[1]))
    }

    static func commonItem(_ group: [Rucksack]) -> ItemType {
        group.reduce(group[0].itemSet, { $0.intersection($1.itemSet) }).first!
    }
}

print("")

enum Part2 {
    static func run(_ source: InputData) {
        let input = source.data
        let groups = input.map(Rucksack.init(line:)).chunked(into: 3)
        let commonItems = groups.map(Rucksack.commonItem(_:))
        let total = commonItems.map(\.priority).reduce(0, +)

        print("Part 2 (\(source)): \(total)")
    }
}

InputData.allCases.forEach(Part2.run)
