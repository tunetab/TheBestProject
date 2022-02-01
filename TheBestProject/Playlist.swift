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
    //var date: Date
    //var author: User
    //var description: String
    var image: UIImage
    //var tracks: [Track]
}

//extension Playlist: Codable {  }

extension Playlist: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        return lhs.name == rhs.name
    }
}

extension Playlist: Comparable {
    static func < (_ lhs: Playlist, _ rhs: Playlist) -> Bool {
        return lhs.name < rhs.name
    }
}

