//
//  Track.swift
//  PlayMusic
//
//  Created by Felipe Leite on 19/11/22.
//

import Foundation

struct TrackResponse: Codable {
    
    var data: [ Track ]

}

struct Track: Codable, Hashable {

    var id: Int
    var title: String
    var preview: String
    var artist: Artist
    var album: Album

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.id == rhs.id
    }

}
