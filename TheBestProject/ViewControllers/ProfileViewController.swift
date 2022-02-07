//
//  ProfileViewController.swift
//  TheBestProject
//
//  Created by Стажер on 28.01.2022.
//

import UIKit
private let reuseIdentifier = "Cell"

class ProfileViewController: UIViewController, UICollectionViewDelegate, UIContextMenuInteractionDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var playlists: [Playlist] {
        return Settings.shared.playlists
    }
    
    // MARK: dataSource
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
        
        collectionView.delegate = self
        
        imageView.isUserInteractionEnabled = true
        let interaction = UIContextMenuInteraction(delegate: self)
        imageView.addInteraction(interaction)
        
        createDataSource()
        collectionView.setCollectionViewLayout(createLayout(), animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateView()
    }
    
    // MARK: updateView()
    
    func updateView() {
        nameLabel.text = Settings.shared.currentUser.name
        bioLabel.text = Settings.shared.currentUser.bio
        imageView.image = Settings.shared.currentUser.image?.getImage() ?? UIImage(systemName: "person.fill")
        
        self.dataSource.apply(self.snapshot)
    }
    
    // MARK: createDataSource()
    func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Playlist>(collectionView: collectionView, cellProvider: {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaylistCell", for: indexPath) as! PlaylistCollectionViewCell
            cell.playListImageView.image = item.image.getImage()
            cell.playlistNameLabel.text = item.name
            return cell
        })
        dataSource.apply(snapshot)
    }
    
    //MARK: createLayout()
    func createLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(63)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(65)), subitem: item, count: 1)
        let spacing: CGFloat = 8
        group.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: 0, bottom: spacing, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    //MARK: LookingClosureToPlaylists
    @IBSegueAction func openPlaylist(_ coder: NSCoder, sender: Any?) -> PlaylistViewController? {
        let playlistController = PlaylistViewController(coder: coder)
        
        if let cell = sender as? PlaylistCollectionViewCell, let indexPath = collectionView.indexPath(for: cell) {
            let selectedPlaylist = playlists[indexPath.item]
            playlistController?.playlist = selectedPlaylist
            return playlistController
        } else {
            return playlistController
        }
    }

    // MARK: PlaylistContextMenu
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let item = self.dataSource.itemIdentifier(for: indexPath)!
            
            let deletePlaylist = UIAction(title: "Delete") { [weak self] (action) in
                self!.showDeleteAlert(item)
            }
            
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [deletePlaylist])
        }
        return config
    }
    
    // MARK: deleteAlert()
    func showDeleteAlert(_ playlist: Playlist) {
        let alertController = UIAlertController(title: "Are You sure to delete playlist \(playlist.name)?", message: nil, preferredStyle: .alert)
        alertController.addAction(.init(title: "Yes", style: .cancel, handler: { [weak self] _ in
            guard let self = self else { return }
            Settings.shared.deletePlaylist(playlist)
            self.updateView()
        }) )
        alertController.addAction(.init(title: "Cancel", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: profileContextMenu
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions -> UIMenu in
            let edit = UIAction(title: "Edit Profile Image", image: nil) { (action) in
                self.showMediaAlert()
            }
            return UIMenu(title: "", children: [edit])
        }
        return configuration
    }
    
    // MARK: mediaAlert()
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
        
        alertController.popoverPresentationController?.sourceView = self.imageView
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: imagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        
        Settings.shared.currentUser.image = Image(withImage: selectedImage)
        self.updateView()
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: unwindSegues
    
    @IBAction func unwindtoProfilePage(segue: UIStoryboardSegue) {
        guard segue.identifier == "createPlaylist",
            let _ = segue.source as? CreatePlaylistViewController else { return }
        
        self.updateView()
    }
}
