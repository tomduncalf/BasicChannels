//
//  Sequence.swift
//  BasicChannels
//
//  Created by Tom Duncalf on 30/05/2021.
//

import Foundation
import AudioKit

class Melody : EnginePart {
    let sampler: Sampler
    let delay: Delay
    let reverb: CostelloReverb
    let reverbDryWet: DryWetMixer
    var callback: CallbackInstrument! = nil
    var track: SequencerTrack! = nil
    var callbackTrack: SequencerTrack! = nil

    required init(_ engine: BasicEngine) {
        sampler = Sampler(singleCycleSamplePath: "AKWF_bw_squ/AKWF_squ_0015.wav")
        
        delay = Delay(sampler)
        delay.feedback = 90
        delay.time = engine.secsPerBeat * (4 / 3)
        delay.dryWetMix = 35
        delay.lowPassCutoff = 800
        
        reverb = CostelloReverb(delay)
        reverb.feedback = 0.7
        
        reverbDryWet = DryWetMixer(reverb, delay)
        reverbDryWet.balance = 0.5
        
        sampler.isMonophonic = 1
        sampler.attackDuration = 0.01
        sampler.decayDuration = 0.5
        sampler.sustainLevel = 0
        sampler.releaseDuration = 0.3
        
        // TODO This is a bit clicky
        sampler.filterEnable = 1
        sampler.filterCutoff = 0
        sampler.filterResonance = 0.5
        sampler.filterStrength = 1
        sampler.filterAttackDuration = 0.01
        sampler.filterDecayDuration = 0.05
        sampler.filterSustainLevel = 0
        sampler.filterReleaseDuration = 0
        sampler.keyTrackingFraction = 0.0
        sampler.filterEnvelopeVelocityScaling = 1
        
        sampler.masterVolume = 0.05
        
        callback = CallbackInstrument(midiCallback: { (status, note, _) in
            if (status != 128) {
                return
            }
            
            self.sampler.filterStrength = Float.random(in: 0.2...3)
        })

        track = engine.sequencer.addTrack(for: sampler)
        callbackTrack = engine.sequencer.addTrack(for: callback)
        
        generateNewMelody()
        
        engine.mixer.addInput(reverbDryWet)
        engine.mixer.addInput(callback)
    }
    
    func generateNewMelody() {
        track.length = 8
        callbackTrack.length = 8
        
        let baseSequenceNote: UInt8 = 60
        var isFirstNote = true
            
        for beat in stride(from: 0.0, to: 4.0, by: 0.25) {
            if (Float.random(in: 0...1) > 0.6) {
                let interval = isFirstNote ? 0 : [0, 3, 7, 12, 3 + 12].randomElement()!

                isFirstNote = false
                
                track.sequence.add(noteNumber: baseSequenceNote + UInt8(interval), velocity: UInt8.random(in: 0...127), position: beat, duration: 1)
                callbackTrack.sequence.add(noteNumber: baseSequenceNote + UInt8(interval), velocity: UInt8.random(in: 0...127), position: beat, duration: 1)
            }
        }
    }
}
