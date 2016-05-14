//
//  PathfindingNode.swift
//  CoronaPathfinding
//
//  Created by Cooper Knaak on 12/1/15.
//  Copyright © 2015 Cooper Knaak. All rights reserved.
//

import UIKit
import OmniSwift

public final class PathfindingNode<T: Hashable/*: PathfindingProtocol*/>: /*NSObject, PathfindingProtocol,*/Hashable, CustomStringConvertible {
    
    public private(set) var parent:PathfindingNode<T>? = nil
    public private(set) var movementCost = 0
    public let hValue:Int
    public var fValue:Int { return self.hValue + self.movementCost }
    public let state:T
    
    public /*override */var hashValue:Int { return self.state.hashValue }
    public /*override */var description:String { return "\(self.state)" }
    
    public init(state:T, hValue:Int) {
        self.state  = state
        self.hValue = hValue
    }
    /*
    public func adjacentStates() -> [PathfindingNode<T>] {
        return self.state.adjacentStates().map() { PathfindingNode(state: $0) }
    }
    
    public func gValue() -> Int {
//        return self.state.gValue()
        return self.movementCost
    }
    
    public func hValue(finalState:PathfindingNode<T>) -> Int {
        return self.state.hValue(finalState.state)
    }
    
    public func hValue(finalState:T) -> Int {
        return self.state.hValue(finalState)
    }

    public func fValue(finalState:PathfindingNode<T>) -> Int {
        return self.hValue(finalState) + self.gValue()
    }
    
    public func fValue(finalState:T) -> Int {
        return self.state.fValue(finalState)
    }*/
    
    public func setParent(parent: PathfindingNode<T>, g: Int) {
        self.parent = parent
        self.movementCost = parent.movementCost + g
    }
    
    public func getPath() -> [T] {
        return (self.parent?.getPath() ?? []) + [self.state]
    }

}

public func ==<T: Hashable/*PathfindingProtocol*/>(lhs:PathfindingNode<T>, rhs:PathfindingNode<T>) -> Bool {
    return lhs.state == rhs.state
}
