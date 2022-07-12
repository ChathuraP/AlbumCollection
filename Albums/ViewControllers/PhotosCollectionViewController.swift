//
//  PhotosCollectionViewController.swift
//  Albums
//
//  Created by Chathura Palihakkara on 11/7/22.
//

import UIKit
import CocoaLumberjack

class PhotosCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var album: Album? = nil
    
    private var photos: [Photo] = [] {
        didSet {
            if self.photos.count > 0 {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let photoAlbum = album,
            photoAlbum.id != -1 {
            self.getPhotos(albumId: photoAlbum.id)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        if let album = album {
            self.title = album.title
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionViewLayout.invalidateLayout()
    }
        
    // MARK: - API Network calls
    private func getPhotos(albumId: Int) {
        if let selectedAlbum = self.album {
            let requestURL: String = Constants.URLs.baseURL + Constants.APIs.photoAlbum + String(selectedAlbum.id)
            DispatchQueue.global(qos: .userInitiated).async {
                APIService.shared.fetchPhotosForAlbum(requestURL: requestURL, completionHandler: { [self] (getResponse:  () throws -> [Photo]) in
                    do {
                        let photos = try getResponse()
                        self.photos = photos
                    } catch let error {
                        //                    self.reloadAlbumsView.isHidden = false
                        DDLogError("func:getPhotos #\(error)")
                    }
                })
            }
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imageFullscreenSegue",
           let index = sender as? Int,
           let vc = segue.destination as? FullImageViewController,
           let selectedPhoto = self.photos[index] as? Photo {
            vc.photoData = selectedPhoto
        }
    }
}

extension PhotosCollectionViewController {

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageThumbCellIdentifier", for: indexPath) as? PhotoThumbnailViewCell, self.photos.count > 0 {
            cell.photoData = photos[indexPath.row]
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "imageFullscreenSegue", sender: indexPath.row)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 3
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let paddingWidth = layout.minimumInteritemSpacing * itemsPerRow + CGFloat(16*2)
        let availableWidth = collectionView.frame.width - paddingWidth
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
}

