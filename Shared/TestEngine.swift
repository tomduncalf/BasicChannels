//
//  TestEngine.swift
//  BasicChannels
//
//  Created by Tom Duncalf on 26/05/2021.
//

import Foundation
import AudioKit
import CAudioKit
import AVFoundation

class TestEngine {
    let engine = AudioEngine()
    let drumSampler = AppleSampler()
    let chordSampler: Sampler
    let sequencer = Sequencer()
    var callbackInst = CallbackInstrument()
    let mixer = Mixer()
//    let chordFilter: MoogLadder
    let chordDelay: Delay
    
    var lastChordHadAttack = false

    init() {
        let chordSample: AVAudioFile
        
        do {
            let sampleNames = ["bass_drum_C1", "snare_D1", "closed_hi_hat_F#1"]
            let sampleFiles = try sampleNames.map { (name) -> AVAudioFile in
                try AVAudioFile(forReading: (Bundle.main.resourceURL?.appendingPathComponent("Samples/\(name).wav"))!)
            }
            try drumSampler.loadAudioFiles(sampleFiles)
            
        } catch let err {
            Log("Error loading sample \(err)")
        }

        chordSample = try! AVAudioFile(forReading: (Bundle.main.resourceURL?.appendingPathComponent("Samples/synth_chord_cmin.wav"))!)

        let desc = SampleDescriptor(noteNumber: 26,
                                 noteFrequency: 44100.0 / 600,
                                 minimumNoteNumber: 0,
                                 maximumNoteNumber: 127,
                                 minimumVelocity: 0,
                                 maximumVelocity: 127,
                                 isLooping: false,
                                 loopStartPoint: 0.0,
                                 loopEndPoint: 1.0,
                                 startPoint: 0.0,
                                 endPoint: 0.0)
        chordSampler = Sampler(sampleDescriptor: desc, file: chordSample)
        chordSampler.buildSimpleKeyMap()
        
        let drumTrack = sequencer.addTrack(for: drumSampler)
        drumTrack.length = 4
        for beat in stride(from: 0.0, to: 4.0, by: 0.25) {
            if (beat.truncatingRemainder(dividingBy: 1) == 0) {
                drumTrack.sequence.add(noteNumber: 24, position: Double(beat), duration: 1.0)
            }
//            if (beat.truncatingRemainder(dividingBy: 2) == 1) {
//                drumTrack.sequence.add(noteNumber: 26, position: Double(beat), duration: 1.0)
//            }
            drumTrack.sequence.add(noteNumber: 30, velocity: UInt8.random(in: 40...80), position: Double(beat), duration: 1.0)
        }
        
        chordSampler.attackDuration = 0.01
        chordSampler.decayDuration = 0.3
        chordSampler.sustainLevel = 0
        chordSampler.releaseDuration = 0.5
        
        chordSampler.filterEnable = 1
        chordSampler.filterCutoff = 0
        chordSampler.filterStrength = 1000
        chordSampler.filterAttackDuration = 0
        
        let chordTrack = sequencer.addTrack(for: chordSampler)
        drumTrack.length = 4
        chordTrack.sequence.add(noteNumber: 24, position: 0.5, duration: 1)
                
//        chordFilter = MoogLadder(chordSampler, cutoffFrequency: 5000, resonance: 0.5)
        
        chordDelay = Delay(chordSampler)
        chordDelay.feedback = 70
        chordDelay.time = 0.395
        chordDelay.dryWetMix = 40
        chordDelay.lowPassCutoff = 1500
                
        callbackInst = CallbackInstrument(midiCallback: { (_, note, _) in
            self.chordSampler.filterStrength = Float.random(in: 50...500)
            if (!self.lastChordHadAttack && Float.random(in: 0...1) > 0.33) {
                Log("attack")
                self.chordSampler.filterAttackDuration = Float.random(in: 0.25...1.5)
                self.lastChordHadAttack = true
            } else {
                Log("no attack")
                self.chordSampler.filterAttackDuration = 0
                self.lastChordHadAttack = false
            }
        })

        let callbackTrack = sequencer.addTrack(for: callbackInst)
        callbackTrack.length = 4
        callbackTrack.sequence.add(noteNumber: 1, position: 0, duration: 0)

        mixer.addInput(drumSampler)
        mixer.addInput(chordDelay)
        mixer.addInput(callbackInst)
        
        engine.output = mixer
        
        do {
            try engine.start()
        } catch let err {
            Log("Error starting engine \(err)")
        }
        
//        let timer = Timer.scheduledTimer(withTimeInterval: 1/30, repeats: true) { timer in
//            chordDelay.time += 0.001
//        }

        sequencer.tempo = 120
        sequencer.play()
    }
}
