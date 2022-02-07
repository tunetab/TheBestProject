//
//  SearchCollectionViewController.swift
//  TheBestProject
//
//  Created by Стажер on 28.01.2022.
//

import UIKit

private let reuseIdentifier = "TrackCell"

class SearchCollectionViewController: UICollectionViewController, UISearchResultsUpdating {
    
    let searchController = UISearchController()
    let fetchingItemController = FetchingItemsController()
    
    var items = [Track]()
    
    var searchTask: Task<Void, Never>? = nil
    var imageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    
    // MARK: dataSource
    var dataSource: UICollectionViewDiffableDataSource<String, Track>!
    var itemsSnapshot: NSDiffableDataSourceSnapshot<String, Track> {
        var snapshot = NSDiffableDataSourceSnapshot<String, Track>()
        
        snapshot.appendSections(["Results"])
        snapshot.appendItems(items)
        
        return snapshot
    }
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.automaticallyShowsSearchResultsController = true
        searchController.searchBar.showsScopeBar = true
        searchController.searchBar.scopeButtonTitles = ["Music", "Users"]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createDataSource()
        collectionView.collectionViewLayout = createLayout()
    }
    
    // MARK: searchController Actions
    
    func updateSearchResults(for searchController: UISearchController) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(fetchMatchingItems), object: nil)
        perform(#selector(fetchMatchingItems), with: nil, afterDelay: 0.3)
    }
    
    // MARK: fetchMatchingItems()
    @objc func fetchMatchingItems() {
        
        self.items = []
                
        let searchTerm = searchController.searchBar.text ?? ""
        
        imageLoadTasks.values.forEach { task in task.cancel()}
        imageLoadTasks = [:]
        
        searchTask?.cancel()
        searchTask = Task {
            if !searchTerm.isEmpty {
                
                
                let query = [
                    "term": searchTerm,
                    "media": "music",
                    "lang": "en_us",
                    "limit": "50"
                ]
                
                do {
                    let items = try await fetchingItemController.fetchItems(matching: query)
                    if searchTerm == self.searchController.searchBar.text {
                        self.items = items
                    }
                } catch let error as NSError where error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                    
                } catch {
                    print(error)
                }
                await dataSource.apply(itemsSnapshot, animatingDifferences: true)
                
                
            } else {
                await dataSource.apply(itemsSnapshot, animatingDifferences: true)
            }
            searchTask = nil
        }
    }
    
    // MARK: createDataSource()
    func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<String, Track>(
            collectionView: collectionView, cellProvider: {
                (collectionView, indexPath, item) -> UICollectionViewCell? in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TrackCollectionViewCell
                
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
            }
        )
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
    
    // MARK: contextMenuConfig
    
    private func addingTrackSegue(track: Track) {
        performSegue(withIdentifier: "AddTrackToPlaylists", sender: track)
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let item = self.dataSource.itemIdentifier(for: indexPath)!
            
            let favoriteToggle = UIAction(title: Settings.shared.favoriteTracks.contains(item) ? "Unfavorite" : "Favorite") { (action) in
                Settings.shared.toggleFavorite(item)
            }
            
            let addToPlaylist = UIAction(title: "Add to Playlist") { [weak self] (action) in
                self?.addingTrackSegue(track: item)
            }
            
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [favoriteToggle, addToPlaylist])
        }
        return config
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "AddTrackToPlaylists",
              let choosePlaylistVC = segue.destination as? AddTrackToPlaylistCollectionViewController else { return }
        
        if let trackToAdd = sender as? Track {
            choosePlaylistVC.track = trackToAdd
        }
    }
    
    // MARK: unwind Segue from PlaylistController
    
    @IBAction func unwindFromAddTrackToPlaylist(segue: UIStoryboardSegue) {

    }
}
