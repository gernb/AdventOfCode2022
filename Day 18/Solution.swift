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

        var interiorArea: Int {
            let total = cubes.reduce(0) { result, cube in
                result + cube.allDirections.filter { cubes.contains($0) == false }.count
            }
            let zFace = xRange.count * yRange.count
            let yFace = xRange.count * zRange.count
            let xFace = yRange.count * zRange.count
            return total - (zFace * 2 + yFace * 2 + xFace * 2)
        }

        func isInside(_ cube: Position) -> Bool {
            xRange.contains(cube.x) && yRange.contains(cube.y) && zRange.contains(cube.z)
        }

        func isVoid(_ cube: Position) -> Bool {
            isInside(cube) && cubes.contains(cube) == false && rock.contains(cube) == false
        }

        mutating func fillVoids() {
            var queue = cubes
            while queue.isEmpty == false {
                let cube = queue.removeFirst()
                cube.allDirections.forEach { adjacent in
                    if isVoid(adjacent) {
                        cubes.insert(adjacent)
                        queue.insert(adjacent)
                    }
                }
            }
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

        var exteriorCubes: Set<Position> = []
        func addLine(_ line: [Position]) {
            if let first = line.firstIndex(where: { cubes.contains($0) }),
               let last = line.lastIndex(where: { cubes.contains($0) }) {
                exteriorCubes.formUnion(line[0 ..< first])
                exteriorCubes.formUnion(line[(last + 1 ..< line.count)])
            } else {
                exteriorCubes.formUnion(line)
            }
        }

        for z in zRange {
            for y in yRange {
                let line = xRange.map { Position(x: $0, y: y, z: z) }
                addLine(line)
            }
        }
        for z in zRange {
            for x in xRange {
                let line = yRange.map { Position(x: x, y: $0, z: z) }
                addLine(line)
            }
        }
        for y in yRange {
            for x in xRange {
                let line = zRange.map { Position(x: x, y: y, z: $0) }
                addLine(line)
            }
        }

        return .init(
            cubes: exteriorCubes,
            rock: cubes,
            xRange: xRange,
            yRange: yRange,
            zRange: zRange
        )
    }

    static func run(_ source: InputData) {
        let cubes = Set(source.data.map(Position.init(line:)))
        var water = exteriorFill(cubes)
        water.fillVoids()

        print("Part 2 (\(source)): \(water.interiorArea)")
    }
}
