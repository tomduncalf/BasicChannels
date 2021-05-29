//
//  Progression.swift
//  BasicChannels
//
//  Created by Tom Duncalf on 29/05/2021.
//

import Foundation
import AudioKit
import CAudioKit

class Progression {
    let engine: BasicEngine
    var lengthInBars: Int = 4
    
    // Maybe we just have one ever present callback instrument that resets its count?
    init (_ engine: BasicEngine) {
        self.engine = engine
    }
    
    func onBarCallback(_ barsElapsed: Int) -> Void {
    }
}

class ProgressionManager {
    let engine: BasicEngine
    var activeProgression: Progression

    var barsElapsed = 0
    var callbackInstrument = CallbackInstrument()
    var callbackTrack: SequencerTrack? = nil
    
    init (_ engine: BasicEngine) {
        self.engine = engine
        activeProgression = BreakdownProgression(engine)

        self.callbackInstrument = CallbackInstrument(midiCallback:  { (status, note, _) in
            if (status != 128) {
                return
            }
            
            self.activeProgression.onBarCallback(self.barsElapsed)
            
            self.barsElapsed += 1
        })
        
        callbackTrack = engine.sequencer.addTrack(for: callbackInstrument)
        callbackTrack!.length = 4
        callbackTrack!.loopEnabled = true
        callbackTrack!.sequence.add(noteNumber: 1, position: 0, duration: 0)
        
        engine.mixer.addInput(callbackInstrument)
    }
    
    func teardown() {
        engine.sequencer.removeTrack(track: callbackTrack!)
    }
}

class BreakdownProgression : Progression {
    override init(_ engine: BasicEngine) {
        super.init(engine)
        self.lengthInBars = 16
    }
    
    override func onBarCallback(_ barsElapsed: Int) {
        if (barsElapsed == 4) {
            engine.drumsHighpassFilter.$cutoffFrequency.automate(events: [
                AutomationEvent(targetValue: 2000, startTime: 0, rampDuration: Float(Duration(beats: 12, tempo: engine.tempo).seconds)),
                AutomationEvent(targetValue: 10, startTime: Float(Duration(beats: 16, tempo: engine.tempo).seconds) - 0.1, rampDuration: 0.1)
            ])
        } else if (barsElapsed == 8) {
            engine.openHiHatGain.gain = 0.3
        }
        
        Log(barsElapsed)
    }
}
