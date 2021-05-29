//
//  SequencerExtensions.swift
//  BasicChannels
//
//  Created by Tom Duncalf on 29/05/2021.
//

import Foundation
import AudioKit

extension Sequencer {
    public func removeTrack(track: SequencerTrack) {
        if let index = tracks.firstIndex(where: { $0 === track }) {
            tracks.remove(at: index)
        }
    }
}
