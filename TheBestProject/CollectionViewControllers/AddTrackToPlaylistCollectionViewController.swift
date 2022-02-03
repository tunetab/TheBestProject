//
//  AddTrackToPlaylistCollectionViewController.swift
//  TheBestProject
//
//  Created by Стажер on 02.02.2022.
//

import UIKit

private let reuseIdentifier = "Cell"

class AddTrackToPlaylistCollectionViewController: UICollectionViewController {

    var track: Track?
    
    var playlists: [Playlist] {
        return Settings.shared.playlists
    }
    
    enum Section {
        case playlists
    }

    var dataSource: UICollectionViewDiffableDataSource<Section, Playlist>!
    var snapshot: NSDiffableDataSourceSnapshot<Section, Playlist> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Playlist>()
        
        snapshot.appendSections([.playlists])
        snapshot.appendItems(playlists, toSection: .playlists)
        
        return snapshot
    }
    // MARK: ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("addingController has got track: \(String(describing: track))")
        
        createDataSource()
        collectionView.setCollectionViewLayout(createLayout(), animated: false)
    }
    //MARK: createDataSource()
    func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Playlist>(collectionView: collectionView, cellProvider: {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaylistCell", for: indexPath) as! PlaylistCollectionViewCell
            cell.playListImageView.image = item.image.getImage() ?? UIImage(systemName: "scribble")
            cell.playlistNameLabel.text = item.name
            return cell
        })
        dataSource.apply(snapshot)
    }
    // MARK: createLayout()
    func createLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(63)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(65)), subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 15, bottom: 30, trailing: 15)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: Adding Track to Playlist
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let playlist = dataSource.itemIdentifier(for: indexPath) {
            Settings.shared.addTrack(self.track!, to: playlist)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "FinishAdding",
            let cell = sender as? UICollectionViewCell else { return }
        
        if let indexPath = collectionView.indexPath(for: cell),
            let playlist = dataSource.itemIdentifier(for: indexPath) {
            Settings.shared.addTrack(self.track!, to: playlist)
        }
    }
}