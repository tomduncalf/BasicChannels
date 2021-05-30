//
//  Drums.swift
//  BasicChannels
//
//  Created by Tom Duncalf on 30/05/2021.
//

import Foundation
import AudioKit
import CAudioKit

class Drums : EnginePart {
    let drumSampler = AppleSampler()
    let openHiHatSampler = AppleSampler()
    let openHiHatGain: Fader
    let openHiHatReverb: ChowningReverb
    let highpassFilter: HighPassButterworthFilter

    required init(_ engine: BasicEngine) {
        let drumSampleNames = ["bass_drum_C1", "snare_D1", "closed_hi_hat_F#1"]
        let drumSampleFiles = drumSampleNames.map { (name) -> AVAudioFile in
            try! AVAudioFile(forReading: (Bundle.main.resourceURL?.appendingPathComponent("Samples/\(name).wav"))!)
        }
        try! drumSampler.loadAudioFiles(drumSampleFiles)
        
        try! openHiHatSampler.loadAudioFile(try! AVAudioFile(forReading: (Bundle.main.resourceURL?.appendingPathComponent("Samples/ma_808_A#1.wav"))!))
        
        
        let drumTrack = engine.sequencer.addTrack(for: drumSampler)
        drumTrack.length = 4
        
        let openHiHatTrack = engine.sequencer.addTrack(for: openHiHatSampler)
        openHiHatTrack.length = 4

        for beat in stride(from: 0.0, to: 4.0, by: 0.25) {
            // Kicks
            if (beat.truncatingRemainder(dividingBy: 1) == 0) {
                drumTrack.sequence.add(noteNumber: 24, position: Double(beat), duration: 1.0)
            }
            
            // Closed hi hats
            drumTrack.sequence.add(noteNumber: 30, velocity: UInt8.random(in: 20...40), position: Double(beat), duration: 1.0)
            
            if (beat.truncatingRemainder(dividingBy: 1) == 0.5) {
                openHiHatTrack.sequence.add(noteNumber: 34, position: beat, duration: 1.0)
            }
        }

        highpassFilter = HighPassButterworthFilter(drumSampler)
        highpassFilter.cutoffFrequency = 0
        
        openHiHatGain = Fader(openHiHatSampler)
        openHiHatGain.gain = 0
        
        openHiHatReverb = ChowningReverb(openHiHatGain)
        
        engine.mixer.addInput(highpassFilter)
        engine.mixer.addInput(openHiHatReverb)
    }
}
