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

// MARK: - Part 1

print("Day 08:")

enum Part1 {
    static func run(_ source: InputData) {
        let grid = Grid(trees: source.data)
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

extension Grid {
    func scenicScore(row: Int, column: Int) -> Int {
        if row == 0 || row == (trees.count - 1) || column == 0 || column == (trees[row].count - 1) {
            return 0
        }
        let height = trees[row][column]
        let left = Array(trees[row][0 ..< column].reversed())
        let right = Array(trees[row][(column + 1) ..< trees[row].count])
        let up = Array((0 ..< row).map { trees[$0][column] }.reversed())
        let down = Array(((row + 1) ..< trees.count).map { trees[$0][column] })
        return [left, up, right, down]
            .map { min($0.count, $0.prefix(while: { $0 < height }).count + 1) }
            .reduce(1, *)
    }
}

print("")

enum Part2 {
    static func run(_ source: InputData) {
        let grid = Grid(trees: source.data)
        let scores = grid.trees.indices.flatMap { row in
            grid.trees[row].indices.map { column in
                grid.scenicScore(row: row, column: column)
            }
        }

        print("Part 2 (\(source)): \(scores.max()!)")
    }
}

InputData.allCases.forEach(Part2.run)
