//
//  Settings.swift
//  TheBestProject
//
//  Created by Стажер on 31.01.2022.
//

import Foundation

struct Settings {
    
    let currentUser = User(name: "Sergio", bio: "You know, i'm something of a meloman myself")
    
    enum Setting {
        static let favoriteTracks = "favoriteHabits"
        static let playlists = "playlists"
    }
    
    static var shared = Settings()
    private var defaults = UserDefaults.standard
    
    private func archiveJSON<T: Encodable>(value: T, key: String) {
        let data = try! JSONEncoder().encode(value)
        let string = String(data: data, encoding: .utf8)
        defaults.set(string, forKey: key)
    }
    
    private func unarchiveJSON<T: Decodable>(key: String) -> T? {
        guard let string = defaults.string(forKey: key),
              let data = string.data(using: .utf8) else { return nil }
        return try! JSONDecoder().decode(T.self, from: data)
    }
    
    var favoriteTracks: [Track] {
        get {
            unarchiveJSON(key: Setting.favoriteTracks) ?? []
        }
        set {
            archiveJSON(value: newValue, key: Setting.favoriteTracks)
        }
    }
    
    func toggleFavorite(_ track: Track) {
        var favorite = favoriteTracks
        
        if favorite.contains(track) {
            favorite = favorite.filter { $0 != track }
        } else {
            favorite.append(track)
        }
    }
    
    var playlists: [Playlist] {
        get {
            unarchiveJSON(key: Setting.playlists) ?? []
        }
        set {
            archiveJSON(value: newValue, key: Setting.playlists)
        }
    }
    
}
