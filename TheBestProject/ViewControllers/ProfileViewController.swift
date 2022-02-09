//
//  ProfileViewController.swift
//  TheBestProject
//
//  Created by Стажер on 28.01.2022.
//

import UIKit

class ProfileViewController: UIViewController, UICollectionViewDelegate, UIContextMenuInteractionDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var bioLabel: UILabel!
    @IBOutlet private var collectionView: UICollectionView!
    
    private var playlists: [Playlist] {
        return Settings.shared.playlists
    }
    
    // MARK: dataSource
    private enum Section {
        case playlists
    }
    private var dataSource: UICollectionViewDiffableDataSource<Section, Playlist>!
    private var snapshot: NSDiffableDataSourceSnapshot<Section, Playlist> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Playlist>()
        
        snapshot.appendSections([.playlists])
        snapshot.appendItems(playlists, toSection: .playlists)
        
        return snapshot
    }
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()

        createDataSource()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateView()
    }
    
    //MARK: SetupColectionView()
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.setCollectionViewLayout(createLayout(), animated: false)
    }
    
    // MARK: updateView()
    private func updateView() {
        nameLabel.text = Settings.shared.currentUser.name
        bioLabel.text = Settings.shared.currentUser.bio
        imageView.image = Settings.shared.currentUser.image?.getImage() ?? UIImage(systemName: "person.fill")
        
        imageView.isUserInteractionEnabled = true
        let interaction = UIContextMenuInteraction(delegate: self)
        imageView.addInteraction(interaction)
        
        self.dataSource.apply(self.snapshot)
    }
    
    // MARK: createDataSource()
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Playlist>(collectionView: collectionView, cellProvider: {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistCollectionViewCell.reuseIdentifier, for: indexPath)
            guard let cell = cell as? PlaylistCollectionViewCell else { return cell }
            
            cell.fill(item.name, item.image.getImage())
            
            return cell
        })
        dataSource.apply(snapshot)
    }
    
    //MARK: createLayout()
    private func createLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(63)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(65)), subitem: item, count: 1)
        let spacing: CGFloat = 8
        group.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: 0, bottom: spacing, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    //MARK: openPlaylst
    
    private func openPlaylist(_ playlist: Playlist) {
        performSegue(withIdentifier: "OpenPlaylist", sender: playlist)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.dataSource.itemIdentifier(for: indexPath)!
        
        self.openPlaylist(item)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "OpenPlaylist",
              let PlaylistVC = segue.destination as? PlaylistViewController else { return }
        
        if let playlist = sender as? Playlist {
            PlaylistVC.playlist = playlist
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
    private func showDeleteAlert(_ playlist: Playlist) {
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
    private func showMediaAlert() {
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
