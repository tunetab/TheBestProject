//
//  PlaylistCollectionViewCell.swift
//  TheBestProject
//
//  Created by Стажер on 28.01.2022.
//

import UIKit

class PlaylistCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "PlaylistCell"
    
    @IBOutlet weak var playlistNameLabel: UILabel!
    @IBOutlet weak var playListImageView: UIImageView!
    
    func fill(_ name: String, _ image: UIImage?) {
        self.playlistNameLabel.text = name
        self.playListImageView.image = image ?? UIImage(systemName: "music.note.list")
    }
}
