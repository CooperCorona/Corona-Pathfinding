//
//  APathfinder_Tests.swift
//  CoronaPathfinding
//
//  Created by Cooper Knaak on 8/16/17.
//  Copyright © 2017 Cooper Knaak. All rights reserved.
//

import XCTest
import CoronaStructures
import CoronaPathfinding

class APathfinder_Tests: XCTestCase {
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceExample() {
        let grid = CellularAutomaton(width: 64, height: 64, seed: 1)
        grid.iterate(10)
        grid.connectAllValidIslands()
        self.measure {
            let pathfinder = APathfinder(initial: IntPoint(x: 0, y: 0), final: IntPoint(x: 63, y: 63), delegate: grid)
            do {
                let _ = try pathfinder.findOptimalPath()
                XCTAssert(true)
            } catch {
                XCTAssert(false, "No path could be found.")
            }
        }
    }
    
}
