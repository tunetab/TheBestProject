//
//  Playlist.swift
//  TheBestProject
//
//  Created by Стажер on 31.01.2022.
//

import Foundation
import UIKit

struct Playlist {
    var name: String
    var id: Int
    var date: Date
    var author: User?
    var image: Image
    var tracks: [Track]?
}

extension Playlist: Codable {
    /*
    enum CodingKeys: String, CodingKey {
        case name
        case date
        case author
        case image
        case tracks
    }
    
    init (from encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        
        try values.encode(name, forKey: CodingKeys.name)
        try values.encode(date, forKey: CodingKeys.date)
        try values.encode(author, forKey: CodingKeys.author)
        try values.encode(tracks, forKey: CodingKeys.tracks)
        
        if let image = self.image {
            let data = image.jpegData(compressionQuality: 1.0)
            try values.encode(data, forKey: CodingKeys.image)
        }
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try values.decode(String.self, forKey: CodingKeys.name)
        self.date = try values.decode(Date.self, forKey: CodingKeys.date)
        self.author = try values.decode(User.self, forKey: CodingKeys.author)
        self.tracks = try values.decode([Track].self, forKey: CodingKeys.tracks)
        
        let data = try values.decode(Data.self, forKey: CodingKeys.image)
        try self.init(from: decoder)
        self.image = UIImage(data: data)
    }
     */
}

extension Playlist: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Playlist: Comparable {
    static func < (_ lhs: Playlist, _ rhs: Playlist) -> Bool {
        return lhs.date < rhs.date
    }
}

