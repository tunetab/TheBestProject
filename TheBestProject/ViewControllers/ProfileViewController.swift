//
//  ProfileViewController.swift
//  TheBestProject
//
//  Created by Стажер on 28.01.2022.
//

import UIKit
private let reuseIdentifier = "Cell"

class ProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
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
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = Settings.shared.currentUser.name
        bioLabel.text = Settings.shared.currentUser.bio
        
        createDataSource()
        collectionView.setCollectionViewLayout(createLayout(), animated: false)
    }
    // MARK: createDataSource()
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
    //MARK: createLayout()
    func createLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(63)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(65)), subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
}
