//
//  main.swift
//  Day 14
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

struct Point: Hashable {
    var x: Int
    var y: Int

    var down: Self { .init(x: self.x, y: self.y + 1) }
    var downLeft: Self { .init(x: self.x - 1, y: self.y + 1) }
    var downRight: Self { .init(x: self.x + 1, y: self.y + 1) }

    static let origin = Point(x: 500, y: 0)
}

extension Point {
    init<S: StringProtocol>(input: S) {
        let parts = input
            .trimmingCharacters(in: .whitespaces)
            .components(separatedBy: ",")
        self.x = Int(parts[0])!
        self.y = Int(parts[1])!
    }
}

struct Line {
    let start: Point
    let end: Point

    var points: [Point] {
        if start.x == end.x {
            return (min(start.y, end.y) ... max(start.y, end.y)).map {
                .init(x: start.x, y: $0)
            }
        } else {
            assert(start.y == end.y)
            return (min(start.x, end.x) ... max(start.x, end.x)).map {
                .init(x: $0, y: start.y)
            }
        }
    }

    static func path(from line: String) -> [Line] {
        let points = line.components(separatedBy: " -> ").map(Point.init(input:))
        return points.dropLast().enumerated().map { index, start in
            Line(start: start, end: points[index + 1])
        }
    }
}

extension Collection where Element: Comparable {
    func range() -> ClosedRange<Element> {
        precondition(count > 0)
        let sorted = self.sorted()
        return sorted.first! ... sorted.last!
    }
}

extension Dictionary where Key == Point {
    var xRange: ClosedRange<Int> { keys.map { $0.x }.range() }
    var yRange: ClosedRange<Int> { keys.map { $0.y }.range() }

    func draw(default: Value, overwrite: Bool = true) {
        let xRange = self.xRange
        let yRange = self.yRange
        if overwrite {
            print("\u{001b}[H") // send the cursor home
        }
        for y in yRange {
            for x in xRange {
                let pixel = self[Key(x: x, y: y), default: `default`]
                print(pixel, terminator: "")
            }
            print("")
        }
    }

    func isInRange(_ key: Key) -> Bool {
        xRange.contains(key.x) && yRange.contains(key.y)
    }
}

enum Tile: String, CustomStringConvertible {
    case air = "."
    case rock = "#"
    case source = "+"
    case sand = "o"

    var description: String { self.rawValue }
}

func inputToTiles(_ input: [String]) -> [Point: Tile] {
    var tiles: [Point: Tile] = [.origin: .source]
    input.map(Line.path(from:)).forEach { path in
        path.forEach { line in
            line.points.forEach { tiles[$0] = .rock }
        }
    }
    return tiles
}

// MARK: - Part 1

enum Part1 {
    // returns true if sand came to rest on the map, or false if it falls into the void
    static func produceUnitOfSand(tiles: inout [Point: Tile]) -> Bool {
        var sand = Point.origin
        while true {
            if tiles[sand.down, default: .air] == .air {
                sand = sand.down
            } else if tiles[sand.downLeft, default: .air] == .air {
                sand = sand.downLeft
            } else if tiles[sand.downRight, default: .air] == .air {
                sand = sand.downRight
            } else {
                if tiles.isInRange(sand) {
                    tiles[sand] = .sand
                    return true
                } else {
                    return false
                }
            }
            if tiles.isInRange(sand) == false {
                return false
            }
        }
    }

    static func run(_ source: InputData) {
        var tiles = inputToTiles(source.data)
        var keepProducing = true
        while keepProducing {
            keepProducing = produceUnitOfSand(tiles: &tiles)
        }
        let count = tiles.values.filter { $0 == .sand }.count

        print("Part 1 (\(source)): \(count)")
    }
}

print("Day 14:")
InputData.allCases.forEach(Part1.run)

// MARK: - Part 2

enum Part2 {
    static func run(_ source: InputData) {
        let input = source.data

        print("Part 2 (\(source)):")
    }
}

print("")
InputData.allCases.forEach(Part2.run)
