//
//  PlaylistViewController.swift
//  TheBestProject
//
//  Created by Стажер on 03.02.2022.
//

import UIKit

class PlaylistViewController: UIViewController {
    
    var playlist: Playlist?
    
    var tracks: [Track] {
        return playlist?.tracks ?? []
    }
    
    let storeItemController = StoreItemController()

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var authorOfPlaylistLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    enum Section {
        case tracks
    }
    var dataSource: UICollectionViewDiffableDataSource<Section, Track>!
    var snapshot: NSDiffableDataSourceSnapshot<Section, Track> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Track>()
        
        snapshot.appendSections([.tracks])
        snapshot.appendItems(tracks, toSection: .tracks)
        
        return snapshot
    }
    
    var imageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = playlist?.name
        coverImageView.image = playlist?.image?.getImage() ?? UIImage(systemName: "folder.fill")
        descriptionLabel.text = "Contain \(playlist?.tracks?.count ?? 0). Last change: \(playlist?.date ?? Date())"
        authorOfPlaylistLabel.text = "Made by \(playlist?.author.name ?? "господьБох")"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createDataSource()
        collectionView.setCollectionViewLayout(createLayout(), animated: false)
    }
    
    // MARK: createDataSource()
    func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Track>(collectionView: collectionView, cellProvider: {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackCell", for: indexPath) as! TrackCollectionViewCell
            cell.trackNameLabel.text = item.name
            cell.artistLabel.text = item.artist
            
            self.imageLoadTasks[indexPath]?.cancel()
            self.imageLoadTasks[indexPath] = Task {
                do {
                    let image = try await self.storeItemController.fetchImage(from: item.artworkURL)
                    cell.albumCoverImageView.image = image
                } catch let error as NSError where error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                    // ignore cancellation errors
                } catch {
                    cell.albumCoverImageView.image = UIImage(systemName: "photo")
                    print("Error fetching image: \(error)")
                }
                self.imageLoadTasks[indexPath] = nil
            }
            
            return cell
        })
        dataSource.apply(snapshot)
    }

    // MARK: createLayout()
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(63))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(65))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
            
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
            
        return UICollectionViewCompositionalLayout(section: section)
    }
}
