//
//  HomePageCollectionViewController.swift
//  TheBestProject
//
//  Created by Стажер on 28.01.2022.
//

import UIKit

private let reuseIdentifier = "Cell"

class HomePageCollectionViewController: UICollectionViewController {

    var favoriteTracks: [Track] {
        return Settings.shared.favoriteTracks
    }
    
    let fetchingItemController = FetchingItemsController()
    
    enum Section {
        case tracks
    }
    var dataSource: UICollectionViewDiffableDataSource<Section, Track>!
    var snapshot: NSDiffableDataSourceSnapshot<Section, Track> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Track>()
        
        snapshot.appendSections([.tracks])
        snapshot.appendItems(favoriteTracks, toSection: .tracks)
        
        return snapshot
    }
    
    var imageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createDataSource()
        collectionView.collectionViewLayout = createLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createDataSource()
        collectionView.collectionViewLayout = createLayout()
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
                    let image = try await self.fetchingItemController.fetchImage(from: item.artworkURL)
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
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let item = self.dataSource.itemIdentifier(for: indexPath)!
            
            let favoriteToggle = UIAction(title: Settings.shared.favoriteTracks.contains(item) ? "Unfavorite" : "Favorite") { (action) in
                Settings.shared.toggleFavorite(item)
                self.dataSource.apply(self.snapshot)
            }
            
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [favoriteToggle])
        }
        return config
    }
    
    @IBSegueAction func openTrack(_ coder: NSCoder, sender: Any?) -> PlayerViewController? {
        let playerVC = PlayerViewController(coder: coder)
        
        if let cell = sender as? TrackCollectionViewCell, let indexPath = collectionView.indexPath(for: cell) {
            let track = favoriteTracks[indexPath.item]
            playerVC?.currentTrack = track
            return playerVC
        } else {
            return playerVC
        }
    }

}
