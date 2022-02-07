//
//  Settings.swift
//  TheBestProject
//
//  Created by Стажер on 31.01.2022.
//

import Foundation

struct Settings {
    
    var currentUser = User(name: "Sergio", bio: "You know, i'm something of a meloman myself")
    
    enum Setting {
        static let favoriteTracks = "favoriteHabits"
        static let playlists = "playlists"
        static let currentUser = "cirrentUser"
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
    
    // MARK: favoriteTracks
    var favoriteTracks: [Track] {
        get {
            unarchiveJSON(key: Setting.favoriteTracks) ?? []
        }
        set {
            archiveJSON(value: newValue, key: Setting.favoriteTracks)
        }
    }
    
    mutating func toggleFavorite(_ track: Track) {
        var favorite = favoriteTracks
        
        if favorite.contains(track) {
            favorite = favorite.filter { $0 != track }
        } else {
            favorite.append(track)
        }
        
        favoriteTracks = favorite
    }
    
    // MARK: editing playlist methods
    var playlists: [Playlist] {
        get {
            unarchiveJSON(key: Setting.playlists) ?? []
        }
        set {
            archiveJSON(value: newValue, key: Setting.playlists)
        }
    }
    
    mutating func createPlaylist(withName name: String?) {
        let playlistCount = playlists.count
        
        var playlistID = 0
        repeat {
            playlistID += 1
        } while playlists.filter { $0.id == playlistID } != []
        
        let newPlaylist = Playlist(name: name ?? "Playlist #\(playlistCount + 1)", id: playlistID, date: Date(), author: currentUser, image: Image(withImage: UIImage(systemName: "scribble")!), tracks: [])
        
        playlists.append(newPlaylist)
    }
    
    mutating func addTrack(_ track: Track, to playlist: Playlist) {
        var editingPlaylist = playlists.first { $0 == playlist }!
        let index = playlists.firstIndex(where: { $0 == playlist })!
        playlists.remove(at: index)
        
        if !editingPlaylist.tracks.contains(track) {
            editingPlaylist.tracks.append(track)
            editingPlaylist.date = Date()
        } else {
            print("Track is already exist in the playlist")
        }
        playlists.append(editingPlaylist)
    }
    
    mutating func editCover(_ image: UIImage, to playlist: Playlist) {
        var editingPlaylist = playlists.first { $0 == playlist }!
        let index = playlists.firstIndex(where: { $0 == playlist })!
        playlists.remove(at: index)
        
        editingPlaylist.image = Image(withImage: image)
        
        playlists.append(editingPlaylist)
    }
    
    mutating func deletePlaylist(_ playlist: Playlist) {
        let index = playlists.firstIndex(where: { $0 == playlist })!
        playlists.remove(at: index)
    }
    
    // MARK: Users methods
    /*
    var currentUser: User {
        get {
            unarchiveJSON(key: Setting.currentUser) as! User
        }
        set {
            archiveJSON(value: newValue, key: Setting.currentUser)
        }
    }
    */
}
