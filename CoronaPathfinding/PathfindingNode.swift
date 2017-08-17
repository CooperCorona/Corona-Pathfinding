//
//  PathfindingNode.swift
//  CoronaPathfinding
//
//  Created by Cooper Knaak on 12/1/15.
//  Copyright © 2015 Cooper Knaak. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif
import CoronaConvenience

public final class PathfindingNode<T: Hashable>: Hashable, Comparable, CustomStringConvertible {
    
    public fileprivate(set) var parent:PathfindingNode<T>? = nil
    public fileprivate(set) var movementCost = 0
    public let hValue:Int
    public var fValue:Int { return self.hValue + self.movementCost }
    public let state:T
    
    public var hashValue:Int { return self.state.hashValue }
    public var description:String { return "\(self.state) (\(self.hValue) + \(self.movementCost) = \(self.fValue))" }
    
    public init(state:T, hValue:Int) {
        self.state  = state
        self.hValue = hValue
    }
    
    public func setParent(_ parent: PathfindingNode<T>, g: Int) {
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

public func < <T: Hashable>(lhs:PathfindingNode<T>, rhs:PathfindingNode<T>) -> Bool {
    return lhs.fValue < rhs.fValue
}

public func > <T: Hashable>(lhs:PathfindingNode<T>, rhs:PathfindingNode<T>) -> Bool {
    return lhs.fValue > rhs.fValue
}

public func <= <T: Hashable>(lhs:PathfindingNode<T>, rhs:PathfindingNode<T>) -> Bool {
    return lhs.fValue <= rhs.fValue
}

public func >= <T: Hashable>(lhs:PathfindingNode<T>, rhs:PathfindingNode<T>) -> Bool {
    return lhs.fValue >= rhs.fValue
}
