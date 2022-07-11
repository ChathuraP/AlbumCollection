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
            print("PhotosCollectionViewController receive album \(album.id)")
            self.navigationController?.navigationBar.topItem?.title = album.title
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionViewLayout.invalidateLayout()
    }
    
    private func startLoadingThumbnails() {}
    
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

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
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
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
}

