//
//  Progression.swift
//  BasicChannels
//
//  Created by Tom Duncalf on 29/05/2021.
//

import Foundation
import AudioKit

class Progression {
    let engine: BasicEngine
    var lengthInBars: Int = 4
    
    var barsElapsed = 0
    var callbackInstrument = CallbackInstrument()
    var callbackTrack: SequencerTrack?
    
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
            engine.drumsHighpassFilter.$cutoffFrequency.ramp(to: 10000, duration: Float(Duration(beats: 4, tempo: engine.tempo).seconds))
        }
        Log(barsElapsed)
    }
}
