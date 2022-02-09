//
//  TrackCollectionViewCell.swift
//  TheBestProject
//
//  Created by Стажер on 01.02.2022.
//

import UIKit

class TrackCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TrackCell"
    
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var albumCoverImageView: UIImageView!
    
    func fillLabels(trackName: String, artistName: String) {
        self.trackNameLabel.text = trackName
        self.artistLabel.text = artistName
    }
    
    func fillImage(_ image: UIImage?) {
        self.albumCoverImageView.image = image ?? UIImage(systemName: "scribble")
    }
}
