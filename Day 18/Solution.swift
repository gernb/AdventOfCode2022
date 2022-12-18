//
//  Solution.swift
//  Day 18
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

struct Position: Hashable, CustomStringConvertible {
    var x: Int
    var y: Int
    var z: Int

    var description: String { "\(x),\(y),\(z)" }

    var up: Self { .init(x: x, y: y + 1, z: z) }
    var down: Self { .init(x: x, y: y - 1, z: z) }
    var left: Self { .init(x: x - 1, y: y, z: z) }
    var right: Self { .init(x: x + 1, y: y, z: z) }
    var `in`: Self { .init(x: x, y: y, z: z + 1) }
    var `out`: Self { .init(x: x, y: y, z: z - 1) }

    var allDirections: [Self] {
        [up, down, left, right, `in`, `out`]
    }
}

extension Position {
    init(line: String) {
        let parts = line.components(separatedBy: ",")
        self.x = Int(parts[0])!
        self.y = Int(parts[1])!
        self.z = Int(parts[2])!
    }
}

// MARK: - Part 1

enum Part1 {
    static func run(_ source: InputData) {
        let cubes = Set(source.data.map(Position.init(line:)))
        let surfaceArea = cubes.reduce(0) { result, cube in
            result + cube.allDirections.filter { cubes.contains($0) == false }.count
        }

        print("Part 1 (\(source)): \(surfaceArea)")
    }
}

// MARK: - Part 2

enum Part2 {
    static func run(_ source: InputData) {
        let input = source.data

        print("Part 2 (\(source)):")
    }
}
