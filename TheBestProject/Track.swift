//
//  Track.swift
//  TheBestProject
//
//  Created by Стажер on 28.01.2022.
//

import Foundation
import UIKit

struct Track {
    let trackName: String
    let artWorkUrl100: URL
    //let duration: TimeInterval
    let artistName: String
    //let album: String
}

extension Track: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(trackName)
    }
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.artWorkUrl100 == rhs.artWorkUrl100
    }
}

extension Track: Comparable {
    static func < (_ lhs: Track, _ rhs: Track) -> Bool {
        return lhs.trackName < rhs.trackName
    }
}

extension Track: Codable { }

