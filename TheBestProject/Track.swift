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
    var id: Int
    var artworkURL: URL
    var album: String
    var previewUrl: URL
    
    enum CodingKeys: String, CodingKey {
        case name = "trackName"
        case artist = "artistName"
        case id = "trackId"
        case artworkURL = "artworkUrl100"
        case album = "collectionName"
        case previewUrl = "previewUrl"
    }

    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try values.decode(String.self, forKey: CodingKeys.name)
        self.artist = try values.decode(String.self, forKey: CodingKeys.artist)
        self.id = try values.decode(Int.self, forKey: CodingKeys.id)
        self.artworkURL = try values.decode(URL.self, forKey: CodingKeys.artworkURL)
        self.album = try values.decode(String.self, forKey: CodingKeys.album)
        self.previewUrl = try values.decode(URL.self, forKey: CodingKeys.previewUrl)
    }
}

extension Track: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Track: Comparable {
    static func < (_ lhs: Track, _ rhs: Track) -> Bool {
        return lhs.name < rhs.name
    }
}


