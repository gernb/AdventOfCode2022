//
//  Solution.swift
//  Day 19
//
//  Copyright © 2022 peter bohac. All rights reserved.
//

enum Resource: CaseIterable {
    case ore, clay, obsidian, geode
}

final class Blueprint {
    typealias CostDictionary = [Resource: (ore: Int, clay: Int, obsidian: Int)]
    let id: Int
    let robotCosts: CostDictionary

    lazy var maxOreProductionNeeded = { self.robotCosts.values.map(\.ore).max()! }()
    lazy var maxClayProductionNeeded = { self.robotCosts.values.map(\.clay).max()! }()
    lazy var maxObsidianProductionNeeded = { self.robotCosts.values.map(\.obsidian).max()! }()

    init(line: String) {
        let numbers = line.replacingOccurrences(of: ":", with: "")
            .components(separatedBy: " ")
            .compactMap(Int.init)
        self.id = numbers[0]
        var robotCosts: CostDictionary = [:]
        robotCosts[.ore] = (numbers[1], 0, 0)
        robotCosts[.clay] = (numbers[2], 0, 0)
        robotCosts[.obsidian] = (numbers[3], numbers[4], 0)
        robotCosts[.geode] = (numbers[5], 0, numbers[6])
        self.robotCosts = robotCosts
    }
}

infix operator /+
func /+(n: Int, d: Int) -> Int {
    let division = n.quotientAndRemainder(dividingBy: d)
    return division.quotient + (division.remainder == 0 ? 0 : 1)
}

// MARK: - Part 1

struct State {
    let maxTime = 24
    let blueprint: Blueprint

    var time: Int = 0
    var resources: [Resource: Int] = [.ore: 0, .clay: 0, .obsidian: 0, .geode: 0]
    var robots: [Resource: Int] = [.ore: 1, .clay: 0, .obsidian: 0, .geode: 0]

    var ore: Int { resources[.ore]! }
    var clay: Int { resources[.clay]! }
    var obsidian: Int { resources[.obsidian]! }
    var geodes: Int { resources[.geode]! }
    var oreRobots: Int { robots[.ore]! }
    var clayRobots: Int { robots[.clay]! }
    var obsidianRobots: Int { robots[.obsidian]! }
    var geodeRobots: Int { robots[.geode]! }

    func nextStates() -> [State] {
        guard time < maxTime else { return [] }
        var nextStates: [State] = []
        if obsidianRobots > 0 {
            // we can make geode robots
            let minutesForObsidian = max(0, blueprint.robotCosts[.geode]!.obsidian - obsidian) /+ obsidianRobots
            let minutesForOre = max(0, blueprint.robotCosts[.geode]!.ore - ore) /+ oreRobots
            let minutes = max(minutesForObsidian, minutesForOre)
            if time + minutes < maxTime {
                let state = self.collectResources(advancing: minutes).createRobot(producing: .geode)
                nextStates.append(state)
            }
        }
        if clayRobots > 0 && obsidianRobots < blueprint.maxObsidianProductionNeeded {
            // we can make obsidian robots
            let minutesForClay = max(0, blueprint.robotCosts[.obsidian]!.clay - clay) /+ clayRobots
            let minutesForOre = max(0, blueprint.robotCosts[.obsidian]!.ore - ore) /+ oreRobots
            let minutes = max(minutesForClay, minutesForOre)
            if time + minutes < maxTime {
                let state = self.collectResources(advancing: minutes).createRobot(producing: .obsidian)
                nextStates.append(state)
            }
        }
        if clayRobots < blueprint.maxClayProductionNeeded {
            let minutes = max(0, blueprint.robotCosts[.clay]!.ore - ore) /+ oreRobots
            if time + minutes < maxTime {
                let state = self.collectResources(advancing: minutes).createRobot(producing: .clay)
                nextStates.append(state)
            }
        }
        if oreRobots < blueprint.maxOreProductionNeeded {
            let minutes = max(0, blueprint.robotCosts[.ore]!.ore - ore) /+ oreRobots
            if time + minutes < maxTime {
                let state = self.collectResources(advancing: minutes).createRobot(producing: .ore)
                nextStates.append(state)
            }
        }
        if nextStates.isEmpty {
            let state = self.collectResources(advancing: maxTime - time)
            nextStates.append(state)
        }
        return nextStates
    }

    func collectResources(advancing minutes: Int = 1) -> State {
        guard minutes > 0 else { return self }
        var state = self
        state.time += minutes
        state.robots.forEach { resource, count in
            state.resources[resource]! += count * minutes
        }
        return state
    }

    func createRobot(producing resource: Resource) -> State {
        let costs = blueprint.robotCosts[resource]!
        guard
            resources[.ore]! >= costs.ore,
            resources[.clay]! >= costs.clay,
            resources[.obsidian]! >= costs.obsidian
        else {
            fatalError()
        }
        var state = collectResources()
        state.resources[.ore]! -= costs.ore
        state.resources[.clay]! -= costs.clay
        state.resources[.obsidian]! -= costs.obsidian
        state.robots[resource]! += 1
        return state
    }
}

extension State: CustomStringConvertible {
    var description: String {
        "== Minute \(time) == \(oreRobots),\(clayRobots),\(obsidianRobots),\(geodeRobots) robots, \(ore) ore, \(clay) clay, \(obsidian) obsidian, \(geodes) geodes"
    }
}

func findAllPaths<Node>(from start: Node, using getNextNodes: (Node) -> [Node]) -> [[Node]] {
    var paths: [[Node]] = []
    var queue: [(node: Node, path: [Node])] = [(start, [])]
    while queue.isEmpty == false {
        let (node, path) = queue.removeFirst()
        let nextNodes = getNextNodes(node)
        guard nextNodes.isEmpty == false else {
            paths.append(path)
            continue
        }
        for next in nextNodes {
            queue.append((next, path + [next]))
        }
    }
    return paths
}

enum Part1 {
    static func run(_ source: InputData) {
        let blueprints = source.data.map(Blueprint.init(line:))
        let qualityLevels = blueprints.compactMap { blueprint -> Int? in
            let start = State(blueprint: blueprint)
            let solutions = findAllPaths(from: start) { $0.nextStates() }
            let best = solutions.max(by: { $0.last!.geodes < $1.last!.geodes })!
            print("Blueprint \(blueprint.id): \(best.last!.geodes)")
            return best.last!.geodes * blueprint.id
        }
        let result = qualityLevels.reduce(0, +)

        print("Part 1 (\(source)): \(result)")
    }
}

// MARK: - Part 2

enum Part2 {
    static func run(_ source: InputData) {
//        let input = source.data

        print("Part 2 (\(source)):")
    }
}
