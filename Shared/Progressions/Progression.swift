//
//  Progression.swift
//  BasicChannels
//
//  Created by Tom Duncalf on 29/05/2021.
//

import Foundation

class Progression {
    let engine: BasicEngine
    var lengthInBars: Int = 4
    
    init (_ engine: BasicEngine) {
        self.engine = engine
    }
    
    func onBarCallback(_ barsElapsed: Int) -> Void {
    }
}
