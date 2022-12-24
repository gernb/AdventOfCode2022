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
    typealias Valley = [[[Item]]]
    let valleyStates: [Valley]
    let entrance: Position
    let exit: Position

    init(_ lines: [String]) {
        let valley = lines.map { line in
            line.map { [Item(rawValue: $0)].compactMap { $0 } }
        }
        self.valleyStates = Self.computeAllValleyStates(from: valley)
        self.entrance = .init(x: valley[0].firstIndex(of: [])!, y: 0)
        self.exit = .init(x: valley[valley.height - 1].lastIndex(of: [])!, y: valley.height - 1)
    }

    static func computeAllValleyStates(from valley: Valley) -> [Valley] {
        var result = [valley]
        var state = valley
        while true {
            var nextState = Array(repeating: Array(repeating: [Item](), count: valley.width), count: valley.height)
            state.enumerated().forEach { y, row in
                row.enumerated().forEach { x, contents in
                    let position = Position(x: x, y: y)
                    contents.forEach { item in
                        if item == .wall {
                            nextState[position] = [item]
                        } else {
                            var newPosition = position[keyPath: item.direction]
                            if state[newPosition]!.contains(.wall) {
                                switch item {
                                case .upBlizzard: newPosition = .init(x: x, y: valley.height - 2)
                                case .downBlizzard: newPosition = .init(x: x, y: 1)
                                case .leftBlizzard: newPosition = .init(x: valley.width - 2, y: y)
                                case .rightBlizzard: newPosition = .init(x: 1, y: y)
                                case .wall, .elves: fatalError()
                                }
                            }
                            nextState[newPosition]! += [item]
                        }
                    }
                }
            }
            if nextState == valley {
                break
            } else {
                result.append(nextState)
                state = nextState
            }
        }
        return result
    }
}

func draw(valley: Map.Valley, elvesAt: Position) {
    var valley = valley
    valley[elvesAt] = [.elves]
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

struct State: Hashable {
    let elves: Position
    let time: Int

    func nextStates(with map: Map) -> [State] {
        let time = time + 1
        let valley = map.valleyStates[time % map.valleyStates.count]
        return (elves.adjacent + [elves]).compactMap { position in
            guard let contents = valley[position], contents.isEmpty else {
                return nil
            }
            return .init(elves: position, time: time)
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
            if let previousCost = visited[nextNode], previousCost <= cost {
                continue
            }
            if let queued = queue[nextNode], queued.cost <= cost {
                continue
            }
            queue[nextNode] = (newPath, cost)
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
        let (path, _) = findShortestPath(from: State(elves: map.entrance, time: 0)) { current in
            if current.elves == map.exit {
                return nil
            }
            return current.nextStates(with: map).map { ($0, $0.elves.distance(to: map.exit) + $0.time) }
        }

        print("Part 1 (\(source)): \(path.last!.time)")
    }
}

// MARK: - Part 2

enum Part2 {
    static func run(_ source: InputData) {
        let map = Map(source.lines)
        let (firstTrip, _) = findShortestPath(from: State(elves: map.entrance, time: 0)) { current in
            if current.elves == map.exit {
                return nil
            }
            return current.nextStates(with: map).map { ($0, $0.elves.distance(to: map.exit) + $0.time) }
        }
        let (secondTrip, _) = findShortestPath(from: firstTrip.last!) { current in
            if current.elves == map.entrance {
                return nil
            }
            return current.nextStates(with: map).map { ($0, $0.elves.distance(to: map.entrance) + $0.time) }
        }
        let (thirdTrip, _) = findShortestPath(from: secondTrip.last!) { current in
            if current.elves == map.exit {
                return nil
            }
            return current.nextStates(with: map).map { ($0, $0.elves.distance(to: map.exit) + $0.time) }
        }

        print("Part 2 (\(source)): \(thirdTrip.last!.time)")
    }
}
