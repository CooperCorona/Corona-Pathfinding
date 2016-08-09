//
//  CellularAutomaton.swift
//  KingOfKauffman
//
//  Created by Cooper Knaak on 11/23/15.
//  Copyright © 2015 Cooper Knaak. All rights reserved.
//

import UIKit
import OmniSwift

public protocol CellularAutomatonDelegate {
    
    func neighboringPointsForPoint(point:IntPoint) -> [IntPoint]
    
    var validToInvalidInitialFactor:CGFloat { get }
    
    var validToInvalidConversion:Int { get }
    var invalidToValidConversion:Int { get }
    
}

/**
 Defines a grid that is manipulated via cellular automatons.
 Each tiles is marked true or false. True is considered valid,
 and false is considered invalid. It is up to users to decide
 what those mean in the context of their program.
*/
public class CellularAutomaton: NSObject {

    // MARK: - Types
    
    public struct CellIsland: SequenceType {
        
        public typealias Generator    = Set<IntPoint>.Generator
        
        public let isValid:Bool
        public let points:Set<IntPoint>
        public let edges:Set<IntPoint>
        public let count:Int
        
        private init(isValid:Bool, points:Set<IntPoint>, edges:Set<IntPoint>) {
            self.isValid    = isValid
            self.points     = points
            self.edges      = edges
            self.count      = points.count
        }
        
        public func contains(point:IntPoint) -> Bool {
            return self.points.contains(point)
        }
        
        public func generate() -> Generator {
            return self.points.generate()
        }
        
    }
    
    // MARK: - Properties
    
    public let delegate:CellularAutomatonDelegate
    public let width:Int
    public let height:Int
    public private(set) var tiles:BoolList2D
    
    private var islands:[CellIsland] = []
    private var islandsAreDirty = true
    
    // MARK: - Setup
    
    /**
     Initialize a CellularAutomaton object.
    
    - parameter width: The number of tiles in the grid horizontally.
    - parameter height: The number of tiles in the grid vertically.
    - parameter seed: The number to seed the prng with.
    - parameter delegate: The delegate object. Controls flipping frequency, neighbors, etc.
    */
    public init(width:Int, height:Int, seed:UInt32, delegate:CellularAutomatonDelegate) {
        
        self.delegate   = delegate
        self.width      = width
        self.height     = height
        self.tiles      = BoolList2D(width: width, height: height)
        
        super.init()
        
        srandom(seed)
        for j in 0..<height {
            for i in 0..<width {
                let factor = CGFloat(random()) / CGFloat(0x7fffffff)
                self[(i, j)] = factor >= self.delegate.validToInvalidInitialFactor
            }
        }
    }
    
    public init?(url:NSURL, delegate:CellularAutomatonDelegate = NeumannCellularAutomatonDelegate()) {
        guard let tiles = BoolList2D(contentsOfURL: url) else {
            //Can't return nil until properties are populated with dummy values.
            self.width = 0
            self.height = 0
            self.tiles = BoolList2D(width: 1, height: 1)
            self.delegate = delegate
            super.init()
            return nil
        }
        
        self.delegate   = delegate
        self.width      = tiles.width
        self.height     = tiles.height
        self.tiles      = tiles
        
        super.init()
    }
    
    public convenience init?(file:String, delegate:CellularAutomatonDelegate) {
        let url = NSURL.URLForPath(file, pathExtension: "plist")
        self.init(url: url, delegate: delegate)
    }
    
    public convenience init(width:Int, height:Int, seed:UInt32) {
        self.init(width: width, height: height, seed: seed, delegate: NeumannCellularAutomatonDelegate())
    }
    
    public convenience init(width:Int, height:Int) {
        self.init(width: width, height: height, seed: arc4random(), delegate: NeumannCellularAutomatonDelegate())
    }
    
    public convenience init?(file:String) {
        self.init(file: file, delegate: NeumannCellularAutomatonDelegate())
    }
    
    // MARK: - Accessors
    
    ///Accessor for the validity value of the tile at (x, y)
    public subscript(x:Int, y:Int) -> Bool {
        get {
            if self.pointLiesInGrid(IntPoint(x: x, y: y)) {
                return self.tiles[(x, y)]
            } else {
                return false
            }
        }
        set {
            if self.pointLiesInGrid(IntPoint(x: x, y: y)) {
                self.tiles[(x, y)] = newValue
                self.islandsAreDirty = true
            }
        }
    }
    
    // MARK: - Logic
    
    public func pointLiesInGrid(point:IntPoint) -> Bool {
        return 0 <= point.x && point.x < self.width && 0 <= point.y && point.y < self.height
    }
    
    private func validNeighboringPointsFor(point:IntPoint) -> [IntPoint] {
        var neighbors = self.delegate.neighboringPointsForPoint(point)
        neighbors = neighbors.filter() {
            return $0.withinGridWidth(self.width, height: self.height)
        }
        return neighbors
    }
    
    private func neighborCountOfPoint(point:IntPoint) -> Int {
        //Invalid neighbors (think of a wall in a dungeon) are the neighbors we are counting.
//        return self.validNeighboringPointsFor(point).reduce(0) { $0 + (self[$1.x, $1.y] ? 0 : 1) }
        let points = [
            IntPoint(x: +1, y: +0),
            IntPoint(x: -1, y: +0),
            IntPoint(x: +0, y: +1),
            IntPoint(x: +0, y: -1),
            IntPoint(x: +1, y: +1),
            IntPoint(x: -1, y: +1),
            IntPoint(x: +1, y: -1),
            IntPoint(x: -1, y: -1),
        ]
        return points.map() { $0 + point} .reduce(0) { $0 + (self[$1.x, $1.y] ? 0 : 1) }
    }
    
    ///Updates all tiles based on delegate's rules for
    public func iterate() {
        
        var updateTiles = self.tiles
        for j in 0..<self.tiles.height {
            for i in 0..<self.tiles.width {
                let count = self.neighborCountOfPoint(IntPoint(x: i, y: j))
                if self[(i, j)] && count < self.delegate.validToInvalidConversion {
                    updateTiles[i, j] = false
                } else if !self[(i, j)] && count > self.delegate.invalidToValidConversion {
                    updateTiles[i, j] = true
                }
            }
        }
        self.tiles = updateTiles
        self.islandsAreDirty = true
    }
    
    /**
     Fun fact. After a certain number of iterations, when the grids start looking nice, an even
     number of iterations corresponds to a mostly open grid and an odd number of iterations
     corresponds to a mostly closed grid.
     */
    public func iterate(times:Int) {
        for _ in 0..<times {
            self.iterate()
        }
    }
   
    
    /**
     Gets the island containing the given point.
    */
    public func getIslandAt(point:IntPoint) -> CellIsland {
        
        var reachedTiles    = Set<IntPoint>()
        var edges           = Set<IntPoint>()
        
        reachedTiles.insert(point)
        
        let validity = self[point.x, point.y]
        var queuedTiles:[IntPoint] = [point]
        while let currentTile = queuedTiles.first {
            
            let neighbors = self.validNeighboringPointsFor(currentTile)
            for tile in neighbors {
                
                if self[tile.x, tile.y] != validity {
                    edges.insert(tile)
                } else if !reachedTiles.contains(tile) {
                    reachedTiles.insert(tile)
                    queuedTiles.append(tile)
                }
            }
            
            queuedTiles.removeAtIndex(0)
        }
        
        return CellIsland(isValid: validity, points: reachedTiles, edges: edges)
    }
    
    /**
     Returns all islands (valid & invalid) in this object.
    */
    public func findAllIslands() -> [CellIsland] {
        
        guard self.islandsAreDirty else {
            return self.islands
        }
        
        var tileCount = 0
        var reachedTiles = Set<IntPoint>()
        var islands:[CellIsland] = []
        /*var edges:[IntPoint] = []
        
        func addIslandAndEdges(island:CellIsland, edges currentEdges:Set<IntPoint>) {
            islands.append(island)
            reachedTiles.unionInPlace(island.pointSet)
            tileCount += island.count
            edges += currentEdges
        }
        
        let (firstIsland, firstEdges) = self.getIslandAndEdgesAt(IntPoint())
        addIslandAndEdges(firstIsland, edges: firstEdges)
        
        while let currentEdge = edges.first where tileCount < self.width * self.height {
            if !reachedTiles.contains(currentEdge.hashValue) {
                let (island, edge) = self.getIslandAndEdgesAt(currentEdge)
                addIslandAndEdges(island, edges: edge)
            }
            edges.removeFirst()
        }
        */
        
        //Somehow, this loop is faster than the commented out section!
        jLoop: for j in 0..<self.height {
            for i in 0..<self.width {
                let point   = IntPoint(x: i, y: j)
                if reachedTiles.contains(point) {
                    continue
                }
                
                let island = self.getIslandAt(point)
                reachedTiles.unionInPlace(island.points)
                islands.append(island)
                tileCount += island.points.count
                
                if tileCount == self.width * self.height {
                    break jLoop
                }
            }
        }
        
        self.islandsAreDirty = false
        self.islands = islands
        return islands
    }
    
    /**
     Flips a cell island from valid to invalid or vice-versa. Useful for removing walls or rooms in a dungeon, for instance.
     
     - paramter island: The island to flip.
    */
    public func flipIsland(island:CellIsland) {
        for point in island {
            self[point.x, point.y].flip()
        }
    }
    
    /**
     Flips all the islands of the given validity except the largest one.
     
     - parameter validity: The validity of the islands you wish to remove.
    */
    public func removeSmallestIslands(validity:Bool) {
        var islands = self.findAllIslands().filter() { $0.isValid == validity }
        guard islands.count > 0 else {
            return
        }
        var maxIndex = 0
        var maxCount = 0
        for (i, island) in islands.enumerate() {
            if island.points.count > maxCount {
                maxCount = island.points.count
                maxIndex = i
            }
        }
        islands.removeAtIndex(maxIndex)
        
        for island in islands {
            self.flipIsland(island)
        }
    }
    
    private func findIslandsWithoutBiggestIsland() -> [CellIsland] {
        var islands = self.findAllIslands().filter() { $0.isValid }
        guard islands.count > 0 else {
            return []
        }
        var maxIndex = 0
        var maxCount = 0
        for (i, island) in islands.enumerate() {
            if island.count > maxCount {
                maxIndex = i
                maxCount = island.count
            }
        }
        islands.removeAtIndex(maxIndex)
        return islands
    }
    
    ///Connects each island to another island (except for the biggest one).
    public func connectValidIslands() {
        let islands = self.findIslandsWithoutBiggestIsland()
//        let islands = self.findAllIslands()
        for island in islands {
            let path = self.pathToNearestIslandFrom(island)
            for point in path {
                self[point.x, point.y] = true
                self[point.x + 1, point.y] = true
                self[point.x - 1, point.y] = true
                self[point.x, point.y + 1] = true
                self[point.x, point.y - 1] = true
            }
        }
    }
    
    ///Connects the smallest valid islands to each other until there is only 1 valid island left.
    public func connectAllValidIslands() {
        while (self.findAllIslands().reduce(0) { $0 + ($1.isValid ? 1 : 0) } > 1) {
            self.connectValidIslands()
        }
    }
    
    public func pathToNearestIslandFrom(island:CellIsland) -> [IntPoint] {
        
        var visitedPoints = Set<PathfindingNode<IntPoint>>()
        
        var pointQueue:[PathfindingNode<IntPoint>] = []
        for edge in island.edges {
            let node = PathfindingNode(state: edge, hValue: 0)
            visitedPoints.insert(node)
            pointQueue.append(node/*edge*/)
        }
        
        mainLoop: while let edge = pointQueue.first {
            
            let neighbors = self.validNeighboringPointsFor(edge.state)
            for neighbor in neighbors {
                let ilNeighbor = PathfindingNode(state: neighbor, hValue: 0)
                guard !visitedPoints.contains(ilNeighbor) else {
                    continue
                }
                if self[neighbor.x, neighbor.y] == island.isValid {
                    if !island.contains(neighbor) {
                        return edge.getPath() + [neighbor]
                    } else if edge.movementCost + 1 < ilNeighbor.movementCost {
                        ilNeighbor.setParent(edge, g: 1)
                    }
                } else {
                    pointQueue.append(ilNeighbor)
                    visitedPoints.insert(ilNeighbor)
                    ilNeighbor.setParent(edge, g: 1)
                }
                
            }
            pointQueue.removeFirst()
        }
        
        return []
    }
    
    public func pathFrom(point:IntPoint, to:IntPoint) -> [IntPoint] {
        
        let initialState    = point
        let finalState      = to
        let pathfinder      = APathfinder(initial: initialState, final: finalState, delegate: self)
        let path            = (try? pathfinder.findOptimalPath()) ?? []
        return path
    }
    
    ///Write the tiles to a file that can be read with init(file:delegate:).
    public func writeToFile(file:String) -> Bool {
        return self.tiles.writeToFile(file)
    }
    
    public func getDictionary() -> NSMutableDictionary {
        return self.tiles.getDictionary()
    }
    
}

extension CellularAutomaton: PathfindingDelegate {

    public func statesAdjacentTo(state: IntPoint) -> [(IntPoint, Int)] {
        /*
         *  I don't remember why this is commented out,
         *  it was probably too slow.
         *
        var states:[(IntPoint, Int)] = []
        for j in -1...1 {
            for i in -1...1 {
                let x = i + state.x
                let y = j + state.y
                guard self[x, y] && (i != 0 || j != 0) else {
                    continue
                }
                let moveCost = (i != 0 && j != 0) ? 14 : 10
                states.append((IntPoint(x: x, y: y), moveCost))
            }
        }
        */
        
        var states:[(IntPoint, Int)] = []
        if self[state.x + 1, state.y] {
            states.append((IntPoint(x: state.x + 1, y: state.y), 10))
        }
        if self[state.x, state.y + 1] {
            states.append((IntPoint(x: state.x, y: state.y + 1), 10))
        }
        if self[state.x - 1, state.y] {
            states.append((IntPoint(x: state.x - 1, y: state.y), 10))
        }
        if self[state.x, state.y - 1] {
            states.append((IntPoint(x: state.x, y: state.y - 1), 10))
        }
        if self[state.x + 1, state.y + 1] && self[state.x + 1, state.y] && self[state.x, state.y + 1] {
            states.append((IntPoint(x: state.x + 1, y: state.y + 1), 14))
        }
        if self[state.x - 1, state.y + 1] && self[state.x - 1, state.y] && self[state.x, state.y + 1] {
            states.append((IntPoint(x: state.x - 1, y: state.y + 1), 14))
        }
        if self[state.x + 1, state.y - 1] && self[state.x + 1, state.y] && self[state.x, state.y - 1] {
            states.append((IntPoint(x: state.x + 1, y: state.y - 1), 14))
        }
        if self[state.x - 1, state.y - 1] && self[state.x - 1, state.y] && self[state.x, state.y - 1] {
            states.append((IntPoint(x: state.x - 1, y: state.y - 1), 14))
        }
        
        return states
    }
    
    public func costToMoveFrom(fromState: IntPoint, to toState: IntPoint) -> Int {
        if fromState.x != toState.x && fromState.y != toState.y {
            return 14
        } else {
            return 10
        }
    }
    
    public func distanceFrom(fromState: IntPoint, to toState: IntPoint) -> Int {
        let xDiff = CGFloat(fromState.x - toState.x)
        let yDiff = CGFloat(fromState.y - toState.y)
        return Int(10.0 * sqrt(xDiff * xDiff + yDiff * yDiff))
    }
    
}

