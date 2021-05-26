//
//  TestEngine.swift
//  BasicChannels
//
//  Created by Tom Duncalf on 26/05/2021.
//

import Foundation
import AudioKit
import AVFoundation

class TestEngine {
    let engine = AudioEngine()
    let sampler = AppleSampler()
    let sequencer = Sequencer()
    var callbackInst = CallbackInstrument()
    let mixer = Mixer()
    let shaker = Shaker()

    init() {
        do {
            let sampleNames = ["bass_drum_C1", "snare_D1"]
            let sampleFiles = try sampleNames.map { (name) -> AVAudioFile in
                try AVAudioFile(forReading: (Bundle.main.resourceURL?.appendingPathComponent("Samples/\(name).wav"))!)
            }
            try sampler.loadAudioFiles(sampleFiles)
        } catch let err {
            Log("Error loading sample \(err)")
        }
        
        callbackInst = CallbackInstrument(midiCallback: { (_, note, _) in
            print(note)
        })
        
        let track = sequencer.addTrack(for: sampler)
        track.length = 4
        for beat in 0...3 {
            track.sequence.add(noteNumber: 24, position: Double(beat), duration: 1.0)
            if (beat % 2 == 1) {
                track.sequence.add(noteNumber: 26, position: Double(beat), duration: 1.0)
            }
        }
                
        mixer.addInput(sampler)
        mixer.addInput(callbackInst)
        mixer.addInput(shaker)

        engine.output = mixer

        do {
            try engine.start()
        } catch let err {
            Log("Error starting engine \(err)")
        }
        
        sequencer.tempo = 120
        sequencer.play()
    }
}
