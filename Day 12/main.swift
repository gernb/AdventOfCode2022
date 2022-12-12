//
//  main.swift
//  Day 12
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

struct Position: Hashable {
    var x: Int
    var y: Int

    static let origin = Position(x: 0, y: 0)

    var left: Self { .init(x: x - 1, y: y) }
    var right: Self { .init(x: x + 1, y: y) }
    var up: Self { .init(x: x, y: y + 1) }
    var down: Self { .init(x: x, y: y - 1) }

    var neighbours: [Self] {
        [left, up, right, down]
    }
}

extension Position: CustomStringConvertible {
    var description: String {
        "(\(x), \(y))"
    }
}

struct Map {
    let heights: [[Int]]
    let start: Position
    let goal: Position

    init(input: [String]) {
        var start = Position.origin
        var goal = Position.origin
        self.heights = input.enumerated().map { row, line in
            line.enumerated().map { column, char in
                switch char {
                case "S":
                    start = Position(x: column, y: row)
                    return Int(Character("a").asciiValue!)
                case "E":
                    goal = Position(x: column, y: row)
                    return Int(Character("z").asciiValue!)
                default:
                    return Int(char.asciiValue!)
                }
            }
        }
        self.start = start
        self.goal = goal
    }

    func height(at position: Position) -> Int? {
        guard position.x >= 0 && position.x < heights[0].count &&
                position.y >= 0 && position.y < heights.count else {
            return nil
        }
        return heights[position.y][position.x]
    }
}

func findShortestPath<Node: Hashable>(from start: Node, using getNextNodes: ((Node) -> [Node]?)) -> [Node]? {
    typealias Path = [Node]
    var visited: [Node: Path] = [:]
    var queue: [(node: Node, path: Path)] = [(start, [])]

    while queue.isEmpty == false {
        var (node, path) = queue.removeFirst()
        guard let nextNodes = getNextNodes(node) else {
            return path
        }
        path.append(node)
        for nextNode in nextNodes {
            if let previousPath = visited[nextNode], previousPath.count <= path.count {
                continue
            }
            if queue.contains(where: { $0.node == nextNode } ) {
                continue
            }
            queue.append((nextNode, path))
        }
        visited[node] = path
    }

    // No possible path exists
    return nil
}

// MARK: - Part 1

print("Day 12:")

enum Part1 {
    static func run(_ source: InputData) {
        let map = Map(input: source.data)
        let path = findShortestPath(from: map.start) { currentPosition in
            if currentPosition == map.goal {
                return nil
            }
            let currentHeight = map.height(at: currentPosition)!
            return currentPosition.neighbours.compactMap { position in
                guard let height = map.height(at: position) else { return nil }
                guard (height - 1) <= currentHeight else { return nil }
                return position
            }
        }

        print("Part 1 (\(source)): \(path!.count)")
    }
}

InputData.allCases.forEach(Part1.run)

// MARK: - Part 2

extension Map {
    static let lowestHeight = Int(Character("a").asciiValue!)
}

print("")

enum Part2 {
    static func run(_ source: InputData) {
        let map = Map(input: source.data)
        let path = findShortestPath(from: map.goal) { currentPosition in
            if map.height(at: currentPosition) == Map.lowestHeight {
                return nil
            }
            let currentHeight = map.height(at: currentPosition)!
            return currentPosition.neighbours.compactMap { position in
                guard let height = map.height(at: position) else { return nil }
                guard (currentHeight - height) <= 1 else { return nil }
                return position
            }
        }

        print("Part 2 (\(source)): \(path!.count)")
    }
}

InputData.allCases.forEach(Part2.run)
