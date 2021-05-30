//
//  Chords.swift
//  BasicChannels
//
//  Created by Tom Duncalf on 30/05/2021.
//

import Foundation
import AudioKit

class Stab : EnginePart {
    let sampler: Sampler
    let delay: Delay
    var callback: CallbackInstrument! = nil

    var lastChordHadAttack = false

    required init(_ engine: BasicEngine) {
        sampler = Sampler(singleCycleSamplePath: "AKWF_0010/AKWF_0908.wav")
        
        sampler.attackDuration = 0.01
        sampler.decayDuration = 0.5
        sampler.sustainLevel = 0
        sampler.releaseDuration = 0.5
        
        sampler.filterEnable = 1
        sampler.filterCutoff = 0
        sampler.filterResonance = 0.3
        sampler.filterStrength = 1000
        sampler.filterAttackDuration = 0
        
        sampler.masterVolume = 0.2
        
        let track = engine.sequencer.addTrack(for: sampler)
        track.length = 4
        let baseNote: UInt8 = 48
        track.sequence.add(noteNumber: baseNote + 0, position: 0.5, duration: 1)
        track.sequence.add(noteNumber: baseNote + 3, position: 0.5, duration: 1)
        track.sequence.add(noteNumber: baseNote + 7, position: 0.5, duration: 1)
        
        delay = Delay(sampler)
        delay.feedback = 80
        delay.time = engine.secsPerBeat * (3 / 4)
        delay.dryWetMix = 40
        delay.lowPassCutoff = 1200
        
        callback = CallbackInstrument(midiCallback: { (status, note, _) in
            if (status != 128) {
                return
            }
            
            self.sampler.filterStrength = Float.random(in: 5...200)
            if (!self.lastChordHadAttack && Float.random(in: 0...1) > 0.25) {
                self.sampler.filterAttackDuration = Float.random(in: 0.25...2.5)
                self.lastChordHadAttack = true
            } else {
                self.sampler.filterAttackDuration = 0
                self.lastChordHadAttack = false
            }
        })
        
        let callbackTrack = engine.sequencer.addTrack(for: callback)
        callbackTrack.length = 4
        callbackTrack.sequence.add(noteNumber: 1, position: 0, duration: 0)
        
        engine.mixer.addInput(delay)
        engine.mixer.addInput(callback)
    }
}
