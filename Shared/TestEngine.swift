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

        callbackInst = CallbackInstrument(midiCallback: { (_, note, _) in
            print(note)
        })
        
        let drumTrack = sequencer.addTrack(for: drumSampler)
        drumTrack.length = 4
        for beat in stride(from: 0.0, to: 4.0, by: 0.25) {
//            if (beat.truncatingRemainder(dividingBy: 1) == 0) {
//                drumTrack.sequence.add(noteNumber: 24, position: Double(beat), duration: 1.0)
//            }
//            if (beat.truncatingRemainder(dividingBy: 2) == 1) {
//                drumTrack.sequence.add(noteNumber: 26, position: Double(beat), duration: 1.0)
//            }
//            drumTrack.sequence.add(noteNumber: 30, position: Double(beat), duration: 1.0)
        }
        
        let chordTrack = sequencer.addTrack(for: chordSampler)
        drumTrack.length = 4
        chordTrack.sequence.add(noteNumber: 60, position: 1.5, duration: 1)
                
//        chordFilter = MoogLadder(chordSampler, cutoffFrequency: 5000, resonance: 0.5)
        
        chordDelay = Delay(chordSampler)
        chordDelay.feedback = 70
        chordDelay.time = 0.40
        chordDelay.dryWetMix = 40
        chordDelay.lowPassCutoff = 1000
        
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
