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
    static func surfaceArea(of cubes: Set<Position>) -> Int {
        cubes.reduce(0) { result, cube in
            result + cube.allDirections.filter { cubes.contains($0) == false }.count
        }
    }

    static func run(_ source: InputData) {
        let lava = Set(source.data.map(Position.init(line:)))

        print("Part 1 (\(source)): \(surfaceArea(of: lava))")
    }
}

// MARK: - Part 2

extension Collection {
    func range<Value: Comparable>(of property: KeyPath<Element, Value>) -> ClosedRange<Value> {
        let values = self.map { $0[keyPath: property] }.sorted()
        return values.first! ... values.last!
    }
}

extension ClosedRange where Bound: Numeric {
    func extened(by value: Bound) -> ClosedRange {
        lowerBound - value ... upperBound + value
    }
}

struct BoundingBox {
    let xRange: ClosedRange<Int>
    let yRange: ClosedRange<Int>
    let zRange: ClosedRange<Int>

    var min: Position {
        .init(x: xRange.lowerBound, y: yRange.lowerBound, z: zRange.lowerBound)
    }

    var surfaceArea: Int {
        let zFace = xRange.count * yRange.count
        let yFace = xRange.count * zRange.count
        let xFace = yRange.count * zRange.count
        return zFace * 2 + yFace * 2 + xFace * 2
    }

    func extended(by value: Int) -> Self {
        .init(
            xRange: xRange.extened(by: value),
            yRange: yRange.extened(by: value),
            zRange: zRange.extened(by: value)
        )
    }

    func contains(_ position: Position) -> Bool {
        xRange.contains(position.x) && yRange.contains(position.y) && zRange.contains(position.z)
    }

    func floodFill(from start: Position? = nil, shouldFill: (Position) -> Bool = { _ in true }) -> Set<Position> {
        var filled: Set<Position> = [start ?? min]
        var queue = filled
        while queue.isEmpty == false {
            let position = queue.removeFirst()
            position.allDirections.forEach { next in
                if self.contains(next) && filled.contains(next) == false && shouldFill(next) {
                    filled.insert(next)
                    queue.insert(next)
                }
            }
        }
        return filled
    }
}

extension BoundingBox {
    init(containing positions: any Collection<Position>) {
        self.init(
            xRange: positions.range(of: \.x),
            yRange: positions.range(of: \.y),
            zRange: positions.range(of: \.z)
        )
    }
}

enum Part2 {
    static func run(_ source: InputData) {
        let lava = Set(source.data.map(Position.init(line:)))
        let boundingBox = BoundingBox(containing: lava).extended(by: 1)
        let water = boundingBox.floodFill { lava.contains($0) == false }
        let area = Part1.surfaceArea(of: water) - boundingBox.surfaceArea

        print("Part 2 (\(source)): \(area)")
    }
}
