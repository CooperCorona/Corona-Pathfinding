//
//  PathfindingDelegate.swift
//  CoronaPathfinding
//
//  Created by Cooper Knaak on 12/1/15.
//  Copyright © 2015 Cooper Knaak. All rights reserved.
//

import Foundation

public protocol PathfindingDelegate {
    
    associatedtype StateType: Hashable

    /**
     Returns the states adjacent to the given state and the costs
     to move to each of those states. The move cost is not implemented
     in a separate method because I think it will be computationally difficult
     to calculate move costs when you have to consider arbitrary states to move to.
     - parameter state: The current state.
     - returns: An array of tuples, where the first element is the
     (valid) adjacent state and the second element is the cost
     to move to that state.
     */
    func statesAdjacentTo(state:StateType) -> [(StateType, Int)]
    func distanceFrom(fromState:StateType, to toState:StateType) -> Int
    
}