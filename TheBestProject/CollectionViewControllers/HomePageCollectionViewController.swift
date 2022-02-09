//
//  HomePageCollectionViewController.swift
//  TheBestProject
//
//  Created by Стажер on 28.01.2022.
//

import UIKit

class HomePageCollectionViewController: UICollectionViewController {

    private var favoriteTracks: [Track] {
        return Settings.shared.favoriteTracks
    }
    
    let fetchingItemController = FetchingItemsController()
    
    enum Section {
        case tracks
    }
    private var dataSource: UICollectionViewDiffableDataSource<Section, Track>!
    private var snapshot: NSDiffableDataSourceSnapshot<Section, Track> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Track>()
        
        snapshot.appendSections([.tracks])
        snapshot.appendItems(favoriteTracks, toSection: .tracks)
        
        return snapshot
    }
    
    private var imageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createDataSource()
        collectionView.collectionViewLayout = createLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.dataSource.apply(self.snapshot)
    }

    // MARK: createDataSource()
    
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Track>(collectionView: collectionView, cellProvider: {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackCollectionViewCell.reuseIdentifier, for: indexPath)
            
            guard let cell = cell as? TrackCollectionViewCell else { return cell }
            
            cell.fillLabels(trackName: item.name, artistName: item.artist)
            
            self.imageLoadTasks[indexPath]?.cancel()
            self.imageLoadTasks[indexPath] = Task {
                do {
                    let image = try await self.fetchingItemController.fetchImage(from: item.artworkURL)
                    cell.fillImage(image)
                } catch let error as NSError where error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                    // ignore cancellation errors
                } catch {
                    cell.fillImage(nil)
                    print("Error fetching image: \(error)")
                }
                self.imageLoadTasks[indexPath] = nil
            }
            return cell
        })
        dataSource.apply(snapshot)
    }
    
    // MARK: createLayout()
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(63))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(65))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
            
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
            
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: contexMenuConfig
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
    
    //MARK: segue

    private func openPlayer(_ track: Track) {
        performSegue(withIdentifier: "OpenPlayer", sender: track)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.dataSource.itemIdentifier(for: indexPath)!
        
        self.openPlayer(item)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "OpenPlayer",
              let PlayerVC = segue.destination as? PlayerViewController else { return }
        
        if let track = sender as? Track {
            PlayerVC.currentTrack = track
        }
    }
}
