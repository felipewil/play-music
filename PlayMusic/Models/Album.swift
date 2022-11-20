//
//  Album.swift
//  PlayMusic
//
//  Created by Felipe Leite on 19/11/22.
//

import Foundation

struct Album: Codable {

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case coverSmall = "cover_small"
    }

    var id: Int
    var title: String
    var coverSmall: String
    
}
