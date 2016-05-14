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
    /*
    func stateIsValid(state:StateType) -> Bool
    func costToMoveFrom(fromState:StateType, to toState:StateType) -> Int
    */
    func statesAdjacentTo(state:StateType) -> [(StateType, Int)]
    func distanceFrom(fromState:StateType, to toState:StateType) -> Int
//    func costToMoveFrom(fromState:StateType, to toState:StateType) -> Int
    
}