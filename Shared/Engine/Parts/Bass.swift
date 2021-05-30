//
//  Chords.swift
//  BasicChannels
//
//  Created by Tom Duncalf on 30/05/2021.
//

import Foundation
import AudioKit

class Bass : EnginePart {
    let sampler: Sampler

    required init(_ engine: BasicEngine) {
        sampler = Sampler(singleCycleSamplePath: "AKWF_bw_sin/AKWF_sin_0001.wav")
        
        sampler.attackDuration = 0
        sampler.decayDuration = 0.5
        sampler.sustainLevel = 1.0
        sampler.releaseDuration = 0.3
        
        sampler.filterEnable = 1
        sampler.filterCutoff = 10
        sampler.filterStrength = 0
        sampler.filterAttackDuration = 0
        sampler.keyTrackingFraction = 0
        
        sampler.masterVolume = 0.2
        
        let track = engine.sequencer.addTrack(for: sampler)
        track.length = 4
        let baseBassNote: UInt8 = 36
        track.sequence.add(noteNumber: baseBassNote + 0, position: 0, duration: 2)
        track.sequence.add(noteNumber: baseBassNote + 7, position: 3, duration: 0.9)
        
        engine.mixer.addInput(sampler)
    }
}
