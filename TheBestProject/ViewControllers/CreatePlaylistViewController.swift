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
        Settings.shared.createPlaylist(withName: textField.text)
        
    }
    
}
