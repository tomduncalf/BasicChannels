//
//  BreakdownProgression.swift
//  BasicChannels
//
//  Created by Tom Duncalf on 29/05/2021.
//

import Foundation
import AudioKit
import CAudioKit

class BreakdownProgression : Progression {
    override init(_ engine: BasicEngine) {
        super.init(engine)
        self.lengthInBars = 16
    }
    
    override func onBarCallback(_ barsElapsed: Int) {
        if (barsElapsed == 4) {
            engine.drums.highpassFilter.$cutoffFrequency.automate(events: [
                AutomationEvent(targetValue: 2000, startTime: 0, rampDuration: Float(Duration(beats: 12, tempo: engine.tempo).seconds)),
                AutomationEvent(targetValue: 10, startTime: Float(Duration(beats: 16, tempo: engine.tempo).seconds) - 0.1, rampDuration: 0.1)
            ])
        } else if (barsElapsed == 8) {
            engine.drums.openHiHatGain.gain = 0.3
        }
        
        Log(barsElapsed)
    }
}
