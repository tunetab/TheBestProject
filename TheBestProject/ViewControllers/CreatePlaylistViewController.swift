//
//  AddPlaylistViewController.swift
//  TheBestProject
//
//  Created by Стажер on 01.02.2022.
//

import UIKit

class CreatePlaylistViewController: UIViewController {

    @IBOutlet private var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func buttonTapped(_ sender: Any?) {
        if let playlistName = textField.text, !playlistName.isEmpty {
            Settings.shared.createPlaylist(withName: playlistName)
        } else {
            Settings.shared.createPlaylist(withName: nil)
        }
    }
    
}
