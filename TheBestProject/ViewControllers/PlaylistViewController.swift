//
//  PlaylistViewController.swift
//  TheBestProject
//
//  Created by Стажер on 03.02.2022.
//

import UIKit

class PlaylistViewController: UIViewController, UIContextMenuInteractionDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var playlist: Playlist?
    
    var tracks: [Track] {
        return playlist?.tracks ?? []
    }
    
    let fetchingItemController = FetchingItemsController()

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

        navigationItem.title = playlist!.name
        coverImageView.image = playlist!.image.getImage()
        descriptionLabel.text = "Contain \(playlist!.tracks.count). Last change: \(playlist!.date.formatted(date: .abbreviated, time: .omitted))"
        authorOfPlaylistLabel.text = "Made by \(playlist!.author.name)"
        
        let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill")) { (action) in
            self.showDeleteAlert()
        }
        
        let menuBarButton = UIBarButtonItem(title: "Settings", image: UIImage(systemName:"ellipsis"), primaryAction: nil, menu: UIMenu(title: "", children: [delete]))
            
        self.navigationItem.rightBarButtonItem = menuBarButton
        
        coverImageView.isUserInteractionEnabled = true
                
        let interaction = UIContextMenuInteraction(delegate: self)
        coverImageView.addInteraction(interaction)
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
    
    // MARK: contextMenu
    func showDeleteAlert() {
        let alertController = UIAlertController(title: "Are You sure to delete playlist \(self.playlist!.name)?", message: nil, preferredStyle: .alert)
        alertController.addAction(.init(title: "Yes", style: .cancel, handler: { [weak self] _ in
            guard let self = self else { return }
            Settings.shared.deletePlaylist(self.playlist!)
            self.navigationController?.popViewController(animated: true)
        }) )
        alertController.addAction(.init(title: "Cancel", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions -> UIMenu in
            let edit = UIAction(title: "Edit Cover", image: nil) { (action) in
                self.showMediaAlert()
            }
            return UIMenu(title: "", children: [edit])
        }
        return configuration
    }
    
    func showMediaAlert() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (action) in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            })
            alertController.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            })
            alertController.addAction(photoLibraryAction)
        }
        
        alertController.popoverPresentationController?.sourceView = self.coverImageView
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        
        Settings.shared.editCover(selectedImage, to: self.playlist!)
        
        self.dataSource.apply(self.snapshot)
        
        dismiss(animated: true, completion: nil)
    }
    
}
