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
    let sampler = MIDISampler(name: "Test")
    let sequencer = Sequencer()
    var callbackInst = CallbackInstrument()
    let mixer = Mixer()

    init() {
        do {
            let sampleURL = Bundle.main.resourceURL?.appendingPathComponent("Samples/snare_D1.wav")
            try sampler.loadAudioFile(AVAudioFile(forReading: sampleURL!))
        } catch {
            print ("ERROR")
        }
        
        callbackInst = CallbackInstrument(midiCallback: { (_, beat, _) in
//            self.data.currentBeat = Int(beat)
            print(beat)
        })
        
        let track = sequencer.addTrack(for: callbackInst)
        track.length = 4
        track.sequence.add(noteNumber: 24, position: 0.0, duration: 0.4)
                
        mixer.addInput(callbackInst)
        engine.output = mixer

        do {
            try engine.start()
        } catch let err {
            Log(err)
        }
        
        sequencer.tempo = 120
        sequencer.play()
    }
}
