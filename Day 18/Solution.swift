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
    struct Water {
        var cubes: Set<Position>
        let rock: Set<Position>
        let xRange: ClosedRange<Int>
        let yRange: ClosedRange<Int>
        let zRange: ClosedRange<Int>

        var area: Int {
            let total = cubes.reduce(0) { result, cube in
                result + cube.allDirections.filter { cubes.contains($0) == false }.count
            }
            let one = xRange.count * yRange.count * 2
            let two = xRange.count * zRange.count * 2
            let three = yRange.count * zRange.count * 2
            return total - one - two - three
        }

        func isInside(_ cube: Position) -> Bool {
            xRange.contains(cube.x) && yRange.contains(cube.y) && zRange.contains(cube.z)
        }

        mutating func fillNooks() -> Bool {
            var didFill = false
            cubes.forEach { cube in
                cube.allDirections.forEach { adjacent in
                    if isInside(adjacent) && cubes.contains(adjacent) == false && rock.contains(adjacent) == false {
                        didFill = true
                        cubes.insert(adjacent)
                    }
                }
            }
            return didFill
        }
    }

    static func exteriorFill(_ cubes: Set<Position>) -> Water {
        let xRange = {
            let values = cubes.map(\.x).sorted()
            return (values.first! - 1) ... (values.last! + 1)
        }()
        let yRange = {
            let values = cubes.map(\.y).sorted()
            return (values.first! - 1) ... (values.last! + 1)
        }()
        let zRange = {
            let values = cubes.map(\.z).sorted()
            return (values.first! - 1) ... (values.last! + 1)
        }()

        var xExteriorCubes: Set<Position> = []
        for z in zRange {
            for y in yRange {
                let line = xRange.map { Position(x: $0, y: y, z: z) }
                if let first = line.firstIndex(where: { cubes.contains($0) }),
                   let last = line.lastIndex(where: { cubes.contains($0) }) {
                    xExteriorCubes.formUnion(line[0 ..< first])
                    xExteriorCubes.formUnion(line[(last + 1 ..< line.count)])
                } else {
                    xExteriorCubes.formUnion(line)
                }
            }
        }
        var yExteriorCubes: Set<Position> = []
        for z in zRange {
            for x in xRange {
                let line = yRange.map { Position(x: x, y: $0, z: z) }
                if let first = line.firstIndex(where: { cubes.contains($0) }),
                   let last = line.lastIndex(where: { cubes.contains($0) }) {
                    yExteriorCubes.formUnion(line[0 ..< first])
                    yExteriorCubes.formUnion(line[(last + 1 ..< line.count)])
                } else {
                    yExteriorCubes.formUnion(line)
                }
            }
        }
        var zExteriorCubes: Set<Position> = []
        for y in yRange {
            for x in xRange {
                let line = zRange.map { Position(x: x, y: y, z: $0) }
                if let first = line.firstIndex(where: { cubes.contains($0) }),
                   let last = line.lastIndex(where: { cubes.contains($0) }) {
                    zExteriorCubes.formUnion(line[0 ..< first])
                    zExteriorCubes.formUnion(line[(last + 1 ..< line.count)])
                } else {
                    zExteriorCubes.formUnion(line)
                }
            }
        }

        return .init(
            cubes: xExteriorCubes.union(yExteriorCubes).union(zExteriorCubes),
            rock: cubes,
            xRange: xRange,
            yRange: yRange,
            zRange: zRange
        )
    }

    static func run(_ source: InputData) {
        let cubes = Set(source.data.map(Position.init(line:)))
        var water = exteriorFill(cubes)
        while water.fillNooks() {
            print("Added cube(s)")
        }

        print("Part 2 (\(source)): \(water.area)")
    }
}
