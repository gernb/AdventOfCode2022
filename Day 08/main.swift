//
//  main.swift
//  Day 08
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

struct Grid {
    let trees: [[Int]]

    func isVisible(row: Int, column: Int) -> Bool {
        if row == 0 || row == (trees.count - 1) || column == 0 || column == (trees[row].count - 1) {
            return true
        }
        let height = trees[row][column]
        let left = trees[row][0 ..< column]
        let right = trees[row][(column + 1) ..< trees[row].count]
        let up = (0 ..< row).map { trees[$0][column] }
        let down = ((row + 1) ..< trees.count).map { trees[$0][column] }
        return left.allSatisfy({ $0 < height }) || up.allSatisfy({ $0 < height }) ||
            right.allSatisfy({ $0 < height }) || down.allSatisfy({ $0 < height })
    }
}

extension Array where Element == Array<Int> {
    var foo: String {
        self.map { $0.map(String.init).joined(separator: " ") }.joined(separator: "\n")
    }
}

// MARK: - Part 1

print("Day 08:")

enum Part1 {
    static func run(_ source: InputData) {
        let grid = Grid(trees: source.data)
        let v = grid.trees.indices.map { row in
            grid.trees[row].indices.map { column in
                grid.isVisible(row: row, column: column) ? 1 : 0
            }
        }
        let visible = grid.trees.indices.flatMap { row in
            grid.trees[row].indices.map { column in
                grid.isVisible(row: row, column: column) ? 1 : 0
            }
        }
        let count = visible.reduce(0, +)

        print("Part 1 (\(source)): \(count)")
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
