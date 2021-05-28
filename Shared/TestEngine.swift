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
    let bassSampler: Sampler
    let sequencer = Sequencer()
    var callbackInst = CallbackInstrument()
    let mixer = Mixer()
//    let chordFilter: MoogLadder
    let chordDelay: Delay
    
    var lastChordHadAttack = false

    init() {
        do {
            let sampleNames = ["bass_drum_C1", "snare_D1", "closed_hi_hat_F#1"]
            let sampleFiles = try sampleNames.map { (name) -> AVAudioFile in
                try AVAudioFile(forReading: (Bundle.main.resourceURL?.appendingPathComponent("Samples/\(name).wav"))!)
            }
            try drumSampler.loadAudioFiles(sampleFiles)
            
        } catch let err {
            Log("Error loading sample \(err)")
        }

        let desc = SampleDescriptor(noteNumber: 26,
                                 noteFrequency: 44100.0/600,
                                 minimumNoteNumber: 0,
                                 maximumNoteNumber: 127,
                                 minimumVelocity: 0,
                                 maximumVelocity: 127,
                                 isLooping: true,
                                 loopStartPoint: 0.0,
                                 loopEndPoint: 1.0,
                                 startPoint: 0.0,
                                 endPoint: 0.0)

        let chordSample = try! AVAudioFile(forReading: (Bundle.main.resourceURL?.appendingPathComponent("Samples/AKWF/AKWF_0010/AKWF_0908.wav"))!)
        chordSampler = Sampler(sampleDescriptor: desc, file: chordSample)
        chordSampler.buildSimpleKeyMap()
        
        let bassSample = try! AVAudioFile(forReading: (Bundle.main.resourceURL?.appendingPathComponent("Samples/AKWF/AKWF_bw_sin/AKWF_sin_0001.wav"))!)
        bassSampler = Sampler(sampleDescriptor: desc, file: bassSample)
        bassSampler.buildSimpleKeyMap()
        
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
        chordSampler.decayDuration = 0.5
        chordSampler.sustainLevel = 0
        chordSampler.releaseDuration = 0.5
        
        chordSampler.filterEnable = 1
        chordSampler.filterCutoff = 0
        chordSampler.filterResonance = 0.3
        chordSampler.filterStrength = 1000
        chordSampler.filterAttackDuration = 0
        
        chordSampler.masterVolume = 0.2
        
        let chordTrack = sequencer.addTrack(for: chordSampler)
        chordTrack.length = 4
        let baseNote: UInt8 = 48
        chordTrack.sequence.add(noteNumber: baseNote + 0, position: 0.5, duration: 1)
        chordTrack.sequence.add(noteNumber: baseNote + 3, position: 0.5, duration: 1)
        chordTrack.sequence.add(noteNumber: baseNote + 7, position: 0.5, duration: 1)
        
        bassSampler.attackDuration = 0
        bassSampler.decayDuration = 0.5
        bassSampler.sustainLevel = 1.0
        bassSampler.releaseDuration = 0.3
        
        bassSampler.filterEnable = 1
        bassSampler.filterCutoff = 100
        bassSampler.filterStrength = 0
        bassSampler.filterAttackDuration = 0
        
        bassSampler.masterVolume = 0.2
        
        let bassTrack = sequencer.addTrack(for: bassSampler)
        bassTrack.length = 4
        let baseBassNote: UInt8 = 24
        bassTrack.sequence.add(noteNumber: baseBassNote + 0, position: 0, duration: 2)
//        bassTrack.sequence.add(noteNumber: baseBassNote + 0, position: 2.5, duration: 0.5)
        bassTrack.sequence.add(noteNumber: baseBassNote + 7, position: 3, duration: 0.9)
        
        chordDelay = Delay(chordSampler)
        chordDelay.feedback = 80
        chordDelay.time = (60 / 120) * (3 / 4)
        chordDelay.dryWetMix = 40
        chordDelay.lowPassCutoff = 1200
                
        callbackInst = CallbackInstrument(midiCallback: { (status, note, _) in
            if (status != 128) {
                return
            }
            
            self.chordSampler.filterStrength = Float.random(in: 10...400)
            if (!self.lastChordHadAttack && Float.random(in: 0...1) > 0.25) {
                self.chordSampler.filterAttackDuration = Float.random(in: 0.25...2.5)
                self.lastChordHadAttack = true
            } else {
                self.chordSampler.filterAttackDuration = 0
                self.lastChordHadAttack = false
            }
        })

        let callbackTrack = sequencer.addTrack(for: callbackInst)
        callbackTrack.length = 4
        callbackTrack.sequence.add(noteNumber: 1, position: 0, duration: 0)

        mixer.addInput(drumSampler)
        mixer.addInput(chordDelay)
        mixer.addInput(bassSampler)
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
