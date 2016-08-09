//
//  APathfinder.swift
//  Pathfinder
//
//  Created by Cooper Knaak on 10/17/15.
//  Copyright © 2015 Cooper Knaak. All rights reserved.
//

import Foundation
import OmniSwift
    
enum APathfinderError: ErrorType {
    case ImpossiblePath
}

public class APathfinder<PathfindingDelegateType: PathfindingDelegate> {

    typealias T = PathfindingDelegateType.StateType
    
    public let initialState:T
    public let finalState:T
    private let finalStateNode:PathfindingNode<T>
    private var currentState:PathfindingNode<T>
    public let delegate:PathfindingDelegateType
    
    public private(set) var openList:[PathfindingNode<T>]   = []
    public private(set) var closedList = Set<PathfindingNode<T>>()
    
    public init(initial:T, final:T, delegate:PathfindingDelegateType) {
        self.initialState   = initial
        self.finalState     = final
        self.finalStateNode = PathfindingNode(state: final, hValue: 0)
        self.currentState   = PathfindingNode(state: initial, hValue: delegate.distanceFrom(initial, to: final))
        self.delegate       = delegate
    }
    
    public func findOptimalPath() throws -> [T] {
        self.openList.append(PathfindingNode(state: self.initialState, hValue: delegate.distanceFrom(self.initialState, to: self.finalState)))
        while try !self.walkState() {

        }
        return self.currentState.getPath()
    }
    
    public func findOptimalPathAsynchronously(queue:dispatch_queue_t, handler:([T]?) -> Void) {
        dispatch_async(queue) {
            let path = try? self.findOptimalPath()
            handler(path)
        }
    }
    
    public func walkState() throws -> Bool {
        guard let state = self.getLowestState() else {
            throw APathfinderError.ImpossiblePath
        }
        
        self.moveFromOpenToClosed(state)
        
        if state.state == self.finalState {
            self.currentState = state
            return true
        }
        
        let adjacents = self.delegate.statesAdjacentTo(state.state)
        let adjacentStates = adjacents.map() { (PathfindingNode(state: $0.0, hValue: self.delegate.distanceFrom($0.0, to: self.finalState)), $0.1) }

        self.iterateAdjacentStates(adjacentStates, state: state)

        return false
    }
    
    public func iterateAdjacentStates(adjacentStates:[(PathfindingNode<T>, Int)], state:PathfindingNode<T>) {
        for (adjacent, moveCost) in adjacentStates {
            if let existingIndex = self.closedList.indexOf(adjacent) {
                let node = self.closedList[existingIndex]
                if state.movementCost + moveCost < node.movementCost {
                    node.setParent(state, g: moveCost)
                }
            } else {
                if let existingIndex = self.openList.indexOf(adjacent) {
                    let node = self.openList[existingIndex]
                    if state.movementCost + moveCost < node.movementCost {
                        node.setParent(state, g: moveCost)
                    }
                } else {
                    adjacent.setParent(state, g: moveCost)
                    self.openList.append(adjacent)
                }
            }
        }
    }
    
    public func getLowestState() -> PathfindingNode<T>? {
        
        guard var lowState = self.openList.first else {
            return nil
        }
        
        var lowF = lowState.fValue
        for (_, state) in self.openList.enumerateRange(1..<self.openList.count) {
            let stateF = state.fValue
            if stateF < lowF {
                lowState = state
                lowF = stateF
            } else if stateF == lowF {
                let hl = lowState.hValue
                let hc = state.hValue
                if hc < hl {
                    lowState = state
                }
            }
        }
        
        return lowState
    }
    
    public func moveFromOpenToClosed(state:PathfindingNode<T>) -> Bool {
        if let index = self.openList.indexOf(state) {
            self.closedList.insert(self.openList.removeAtIndex(index))
            return true
        }
        /*
        for i in 0..<self.openList.count {
            if state == self.openList[i] {
                let removed = self.openList.removeAtIndex(i)
                self.closedList.insert(removed)
                return true
            }
        }
        */
        return false
    }
    
}
