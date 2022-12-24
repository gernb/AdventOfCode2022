//
//  Solution.swift
//  Day 24
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

struct Position: Hashable, CustomStringConvertible {
    var x: Int
    var y: Int

    var description: String { "(\(x), \(y))" }

    var up: Self { .init(x: x, y: y - 1) }
    var down: Self { .init(x: x, y: y + 1) }
    var left: Self { .init(x: x - 1, y: y) }
    var right: Self { .init(x: x + 1, y: y) }

    var adjacent: [Self] {
        [up, down, left, right]
    }

    func distance(to other: Self) -> Int {
        return abs(x - other.x) + abs(y - other.y)
    }
}

extension Array where Element: MutableCollection, Element.Index == Int {
    subscript(_ position: Position) -> Element.Element? {
        get { self[position.x, position.y] }
        set { self[position.x, position.y] = newValue! }
    }

    subscript(_ x: Int, _ y: Int) -> Element.Element? {
        get {
            guard y >= 0 && y < height && x >= 0 && x < width else {
                return nil
            }
            return self[y][x]
        }
        set {
            guard y >= 0 && y < height && x >= 0 && x < width else {
                fatalError()
            }
            self[y][x] = newValue!
        }
    }

    // this assumes the array is 2D with same-size rows
    var width: Int { self[0].count }
    var height: Int { count }
}

enum Item: Character {
    case upBlizzard = "^"
    case downBlizzard = "v"
    case leftBlizzard = "<"
    case rightBlizzard = ">"
    case wall = "#"
    case elves = "E"

    var direction: KeyPath<Position, Position> {
        switch self {
        case .upBlizzard: return \Position.up
        case .downBlizzard: return \Position.down
        case .leftBlizzard: return \Position.left
        case .rightBlizzard: return \Position.right
        case .wall, .elves: fatalError()
        }
    }
}

struct Map: Hashable {
    var valley: [[[Item]]]
    var elves: Position
    var destination: Position
    let exit: Position
    let entrance: Position

    init(_ lines: [String]) {
        self.valley = lines.map { line in
            line.map { [Item(rawValue: $0)].compactMap { $0 } }
        }
        self.entrance = .init(x: valley[0].firstIndex(of: [])!, y: 0)
        self.exit = .init(x: valley[valley.height - 1].lastIndex(of: [])!, y: valley.height - 1)
        self.elves = entrance
        self.destination = exit
    }

    func draw() {
        var valley = valley
        valley[elves] = [.elves]
        let lines = valley.map { row in
            row.map { contents in
                if contents.count > 1 {
                    return "\(contents.count)"
                } else {
                    return String(contents.first?.rawValue ?? ".")
                }
            }.joined()
        }.joined(separator: "\n")
        print(lines)
        print("")
    }

    func moveBlizzards() -> Self {
        var newValley = Array(repeating: Array(repeating: [Item](), count: valley.width), count: valley.height)
        valley.enumerated().forEach { y, row in
            row.enumerated().forEach { x, contents in
                let position = Position(x: x, y: y)
                contents.forEach { item in
                    if item == .wall {
                        newValley[position] = [item]
                    } else {
                        var newPosition = position[keyPath: item.direction]
                        if valley[newPosition]!.contains(.wall) {
                            switch item {
                            case .upBlizzard: newPosition = .init(x: x, y: valley.height - 2)
                            case .downBlizzard: newPosition = .init(x: x, y: 1)
                            case .leftBlizzard: newPosition = .init(x: valley.width - 2, y: y)
                            case .rightBlizzard: newPosition = .init(x: 1, y: y)
                            case .wall, .elves: fatalError()
                            }
                        }
                        newValley[newPosition]! += [item]
                    }
                }
            }
        }
        var next = self
        next.valley = newValley
        return next
    }

    func nextStates() -> [(Self, Int)] {
        var state = self
        var time = 0
        while true {
            if state.elves == state.destination {
                return [(state, time)]
            }
            state = state.moveBlizzards()
            time += 1
            let result = ([state.elves] + state.elves.adjacent).compactMap { next -> Map? in
                guard let contents = state.valley[next], contents.isEmpty else {
                    return nil
                }
                var nextState = state
                nextState.elves = next
                return nextState
            }
            if result.isEmpty || result.count > 1 {
                return result.map { ($0, time) }
            }
            state = result[0]
        }
    }
}

func findShortestPath<Node: Hashable>(from start: Node, using getNextNodes: ((Node) -> [(node: Node, cost: Int)]?)) -> ([Node], Int) {
    typealias Path = [Node]
    var visited: [Node: Int] = [:]
    var queue: [Node: (path: Path, cost: Int)] = [start: ([], 0)]

    while let (node, (path, currentCost)) = queue.min(by: { $0.value.cost < $1.value.cost }) {
        queue.removeValue(forKey: node)
        guard let nextNodes = getNextNodes(node) else {
            return (path + [node], currentCost)
        }
        let newPath = path + [node]
        for (nextNode, cost) in nextNodes {
            let newCost = currentCost + cost
            if let previousCost = visited[nextNode], previousCost <= newCost {
                continue
            }
            if let queued = queue[nextNode], queued.cost <= newCost {
                continue
            }
            queue[nextNode] = (newPath, newCost)
        }
        visited[node] = currentCost
    }

    // No possible path exists
    fatalError()
}

// MARK: - Part 1

enum Part1 {
    static func run(_ source: InputData) {
        let map = Map(source.lines)
        let path = findShortestPath(from: map) { current in
            if current.elves == current.exit {
                return nil
            }
            return current.nextStates()
        }

        print("Part 1 (\(source)): \(path.1)")
    }
}

// MARK: - Part 2

enum Part2 {
    static func run(_ source: InputData) {
        var map = Map(source.lines)
        let (pathForward, forwardCount) = findShortestPath(from: map) { current in
            if current.elves == current.destination {
                return nil
            }
            return current.nextStates()
        }
        map = pathForward.last!
        map.destination = map.entrance
        let (pathBack, backCount) = findShortestPath(from: map) { current in
            if current.elves == current.destination {
                return nil
            }
            return current.nextStates()
        }
        map = pathBack.last!
        map.destination = map.exit
        let (_, returnCount) = findShortestPath(from: map) { current in
            if current.elves == current.destination {
                return nil
            }
            return current.nextStates()
        }
        let result = forwardCount + backCount + returnCount

        print("Part 2 (\(source)): \(result)")
    }
}
