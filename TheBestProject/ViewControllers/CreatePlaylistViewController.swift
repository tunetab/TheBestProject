//
//  AddPlaylistViewController.swift
//  TheBestProject
//
//  Created by Стажер on 01.02.2022.
//

import UIKit

class CreatePlaylistViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    var newPlaylist: Playlist?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func buttonTapped(_ sender: Any?) {
        let playlistCount = Settings.shared.playlists.count
        
        newPlaylist = Playlist(name: textField.text ?? "Playlist #\(playlistCount)", id: playlistCount, date: Date(), author: Settings.shared.currentUser)
    }
    
}
