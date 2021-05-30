//
//  SamplerExtensions.swift
//  BasicChannels
//
//  Created by Tom Duncalf on 30/05/2021.
//

import Foundation
import AudioKit
import CAudioKit

extension Sampler {
    convenience init(singleCycleSamplePath: String) {
        let akSingleCycleDescription = SampleDescriptor(noteNumber: 26,
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
        
        let sample = try! AVAudioFile(forReading: (Bundle.main.resourceURL?.appendingPathComponent("Samples/AKWF/\(singleCycleSamplePath)"))!)

        self.init(sampleDescriptor: akSingleCycleDescription, file: sample)
        buildSimpleKeyMap()
    }
}
