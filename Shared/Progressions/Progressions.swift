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
    
    var barsElapsed = 0
    var callbackInstrument = CallbackInstrument()
    var callbackTrack: SequencerTrack?
    
    // Maybe we just have one ever present callback instrument that resets its count when it hands over?
    init (_ engine: BasicEngine) {
        self.engine = engine
        self.callbackInstrument = CallbackInstrument(midiCallback:  { (status, note, _) in
            if (status != 128) {
                return
            }
            
            self.onBarCallback(self.barsElapsed)
            
            self.barsElapsed += 1
        })
    }
    
    func run() {
        callbackTrack = engine.sequencer.addTrack(for: callbackInstrument)
        let lengthInBeats = lengthInBars * 4
        callbackTrack!.length = Double(lengthInBeats)

        for beat in 0...lengthInBeats {
            if (beat % 4 != 0) {
                continue
            }
            
            callbackTrack!.sequence.add(noteNumber: 1, position: Double(beat), duration: 0)
        }
        
        callbackTrack!.play()
        engine.mixer.addInput(callbackInstrument)
    }
    
    func teardown() {
        engine.sequencer.removeTrack(track: callbackTrack!)
    }
    
    func onBarCallback(_ barsElapsed: Int) -> Void {
    }
}

extension Sequencer {
    public func removeTrack(track: SequencerTrack) {
        if let index = tracks.firstIndex(where: { $0 === track }) {
            tracks.remove(at: index)
        }
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
