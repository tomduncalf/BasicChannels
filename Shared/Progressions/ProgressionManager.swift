//
//  ProgressionManager.swift
//  BasicChannels
//
//  Created by Tom Duncalf on 29/05/2021.
//

import Foundation
import AudioKit

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
