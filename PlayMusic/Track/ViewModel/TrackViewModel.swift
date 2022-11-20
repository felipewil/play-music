//
//  TrackViewModel.swift
//  PlayMusic
//
//  Created by Felipe Leite on 20/11/22.
//

import Foundation

struct TrackViewModel {

    // MARK: Properties
    
    var track: Track
    var title: String { self.track.title }
    var artist: String { self.track.artist.name }
    var coverUrl: String { self.track.album.coverSmall }
    
    // MARK: Initializers

    init(track: Track) {
        self.track = track
    }

}
