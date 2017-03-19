//
//  CellularAutomatonDelegate.swift
//  KingOfKauffman
//
//  Created by Cooper Knaak on 11/23/15.
//  Copyright © 2015 Cooper Knaak. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif
import CoronaConvenience
import CoronaStructures

extension CellularAutomatonDelegate {
    public var validToInvalidInitialFactor:CGFloat { return 0.45 }
}

public struct MooreCellularAutomatonDelegate: CellularAutomatonDelegate {
    
    public var validToInvalidConversion = 4
    public var invalidToValidConversion = 3
    
    public init() {
        
    }
    
    public init(valid:Int, invalid:Int) {
        self.validToInvalidConversion = valid
        self.invalidToValidConversion = invalid
    }
    
    public func neighboringPointsForPoint(_ point: IntPoint) -> [IntPoint] {
        let points:[IntPoint] = [
            point + IntPoint(x:  1, y:  0),
            point + IntPoint(x: -1, y:  0),
            point + IntPoint(x:  0, y:  1),
            point + IntPoint(x:  0, y: -1),
            point + IntPoint(x:  1, y:  1),
            point + IntPoint(x:  1, y: -1),
            point + IntPoint(x: -1, y:  1),
            point + IntPoint(x: -1, y: -1)
        ]
        
        return points
    }
    
}


public struct NeumannCellularAutomatonDelegate: CellularAutomatonDelegate {
    
    public var validToInvalidConversion = 4
    public var invalidToValidConversion = 3
    
    public init() {
        
    }
    
    public init(valid:Int, invalid:Int) {
        self.validToInvalidConversion = valid
        self.invalidToValidConversion = invalid
    }
    
    public func neighboringPointsForPoint(_ point: IntPoint) -> [IntPoint] {
        let points:[IntPoint] = [
            point + IntPoint(x:  1, y:  0),
            point + IntPoint(x: -1, y:  0),
            point + IntPoint(x:  0, y:  1),
            point + IntPoint(x:  0, y: -1)
        ]
        return points
    }
    
}
