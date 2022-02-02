//
//  SearchCollectionViewController.swift
//  TheBestProject
//
//  Created by Стажер on 28.01.2022.
//

import UIKit

private let reuseIdentifier = "Cell"

@MainActor
class SearchCollectionViewController: UICollectionViewController, UISearchResultsUpdating {
    
    let searchController = UISearchController()
    let storeItemController = StoreItemController()
    
    enum Section: CaseIterable {
        case main
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Track>!
    var itemsSnapshot = NSDiffableDataSourceSnapshot<Section, Track>()
    
    var trackSearchTask: Task<Void, Never>? = nil
    var imageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    deinit { trackSearchTask?.cancel() }
    
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.automaticallyShowsSearchResultsController = true
        //searchController.searchBar.showsScopeBar = true
        //searchController.searchBar.scopeButtonTitles = ["Tracks", "Users"]
        
        createDataSource()
        collectionView.collectionViewLayout = createLayout()
    }

    // MARK: searchControllerAction

    func updateSearchResults(for searchController: UISearchController) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(update), object: nil)
        perform(#selector(update), with: nil, afterDelay: 0.3)
    }
    
    // MARK: update()
    
    @objc func update() {
        
        itemsSnapshot.deleteAllItems()
        
        let searchTerm = searchController.searchBar.text ?? ""
        
        imageLoadTasks.values.forEach { task in task.cancel() }
        imageLoadTasks = [:]
        
        trackSearchTask?.cancel()
        trackSearchTask = Task {
            if !searchTerm.isEmpty {
                do {
                    try await fetchAndHandleItemsForSearchScopes(withSearchTerm: searchTerm)
                } catch let error as NSError where error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                    
                } catch {
                    print(error)
                }
            } else {
                await self.dataSource.apply(self.itemsSnapshot, animatingDifferences: true)
            }
            trackSearchTask = nil
        }
    }
    
    // MARK: Handle snapshots
    
    func fetchAndHandleItemsForSearchScopes(withSearchTerm searchTerm: String) async throws {
        try Task.checkCancellation()
        let query = [
            "term": searchTerm,
            "media": "music",
            "lang": "en_us",
            "limit": "50"
        ]
        let items = try await self.storeItemController.fetchItems(matching: query)
        
        if searchTerm == self.searchController.searchBar.text {
            await handleFetchedItems(items)
        }
    }
    
    func handleFetchedItems(_ items: [Track]) async {
        var updatedSnapshot = NSDiffableDataSourceSnapshot<Section, Track>()
        updatedSnapshot.appendItems(items, toSection: .main)
        itemsSnapshot = updatedSnapshot
        
        await dataSource.apply(itemsSnapshot, animatingDifferences: true)
    }
    
    // MARK: createDataSource()
    
    func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Track>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
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
    }

    // MARK: createLayout()
    
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        section.interGroupSpacing = 8
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
