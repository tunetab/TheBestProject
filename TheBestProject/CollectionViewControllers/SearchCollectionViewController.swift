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
    
    var searchItems = [Track]()
    let queryOptions = ["", "music", "artist", ""]
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<String, Track>
    var dataSource: DataSourceType!
    
    var trackSearchTask: Task<Void, Never>? = nil
    deinit { trackSearchTask?.cancel() }
    
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.automaticallyShowsSearchResultsController = true
        searchController.searchBar.showsScopeBar = true
        searchController.searchBar.scopeButtonTitles = ["all", "track", "artist", "users"]
        
    }

    // MARK: searchControllerAction

    func updateSearchResults(for searchController: UISearchController) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(update), object: nil)
        perform(#selector(update), with: nil, afterDelay: 0.3)
    }
    
    // MARK: update()
    
    @objc func update() {
        
        self.searchItems = []
        let searchTerm = searchController.searchBar.text ?? ""
        let mediaType = queryOptions[searchController.searchBar.selectedScopeButtonIndex]
        
        trackSearchTask?.cancel()
        trackSearchTask = Task {
            if !searchTerm.isEmpty {

                let query = [
                    "term": searchTerm,
                    "media": mediaType,
                    "lang": "en_us",
                    "limit": "20"
                ]
                if let items = try? await storeItemController.fetchTracks(matching: query) {
                    self.searchItems = items
                } else {
                    self.searchItems = []
                    print("Items haven't collected")
                }

            }
            self.updateCollectionView()
            trackSearchTask = nil
        }
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
    }
    
    // MARK: updateCollectionView()
    
    func updateCollectionView() {
        var snapshot = NSDiffableDataSourceSnapshot<String, Track>()
        
        snapshot.appendSections(["Results"])
        snapshot.appendItems(self.searchItems, toSection: "Results")
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: createDataSource()
    
    func createDataSource() -> DataSourceType {
        let dataSource = UICollectionViewDiffableDataSource<String, Track> (collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackCell", for: indexPath) as! TrackCollectionViewCell
            cell.trackNameLabel.text = item.trackName
            cell.artistLabel.text = item.artistName
            return cell
        })
        return dataSource
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
