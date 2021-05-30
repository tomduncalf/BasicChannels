//
//  BasicEngine.swift
//  BasicChannels
//
//  Created by Tom Duncalf on 26/05/2021.
//

import Foundation
import AudioKit
import CAudioKit
import AVFoundation

class BasicEngine {
    let engine = AudioEngine()
    
    var drums: Drums! = nil
    var chords: Stab! = nil
    var bass: Bass! = nil
    var melody: Melody! = nil

    let sequencer = Sequencer()
    var callbackInst = CallbackInstrument()
    let mixer = Mixer()
    
    var sequenceTrack: SequencerTrack? = nil
    var sequenceCallbackTrack: SequencerTrack? = nil
    
    var progressionManager: ProgressionManager? = nil

    let tempo: Double = 120
    var secsPerBeat: Float
    
    init() {
        secsPerBeat = Float (60 / tempo)
                
        progressionManager = ProgressionManager(self)
        
        drums = Drums(self)
        chords = Stab(self)
        bass = Bass(self)
        melody = Melody(self)
        
        engine.output = mixer
        
        do {
            try engine.start()
        } catch let err {
            Log("Error starting engine \(err)")
        }

        sequencer.tempo = tempo
        sequencer.play()
    }
}
