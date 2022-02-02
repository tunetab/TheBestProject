//
//  Track.swift
//  TheBestProject
//
//  Created by Стажер on 28.01.2022.
//

import Foundation
import UIKit

struct Track: Codable {
    var name: String
    var artist: String
    var artworkURL: URL
    
    enum CodingKeys: String, CodingKey {
        case name = "trackName"
        case artist = "artistName"
        case artworkURL = "artworkUrl30"
    }

    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try values.decode(String.self, forKey: CodingKeys.name)
        self.artist = try values.decode(String.self, forKey: CodingKeys.artist)
        self.artworkURL = try values.decode(URL.self, forKey: CodingKeys.artworkURL)
    }
}

extension Track: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.artworkURL == rhs.artworkURL
    }
}

extension Track: Comparable {
    static func < (_ lhs: Track, _ rhs: Track) -> Bool {
        return lhs.name < rhs.name
    }
}


