//
//  PhotosCollectionViewController.swift
//  Albums
//
//  Created by Chathura Palihakkara on 11/7/22.
//

import UIKit
import CocoaLumberjack

class PhotosCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, LoadingViewDelegate {
    
    var album: Album? = nil
    
    private var loadingIndicatorView = LoadingViewController()
    private var downloadTask: TaskStatus = .complete {
        didSet {
            self.showIndicator(downloadTask)
        }
    }
    private var photos: [Photo] = [] {
        didSet {
            if self.photos.count > 0 {
                self.collectionView.reloadData()
            }
        }
    }
    private let IMAGE_FULLSCREEN_SEGUE = "imageFullscreenSegue"
    private let IMAGE_THUMB_CELL_IDENTIFIER = "imageThumbCellIdentifier"
    
    // MARK: - LifeCycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        retryButtonTapped()
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
    
    // MARK: - Private functions
    
    /// Restart the download of photo data from the selected album.
    func retryButtonTapped() {
        if let photoAlbum = album,
           photoAlbum.id != -1 {
            self.getPhotos(albumId: photoAlbum.id)
        }
    }
    
    /// Show loading inProgress and Error re-try screens
    /// - Parameter show: Indicates download in progress or completed
    private func showIndicator(_ status: TaskStatus) {
        switch status {
        case .start, .inProgress:
            DispatchQueue.main.async {
                if self.loadingIndicatorView.viewIfLoaded?.window == nil {
                    self.loadingIndicatorView.delegate = self
                    let navi = UINavigationController(rootViewController: self.loadingIndicatorView)
                    navi.modalPresentationStyle = .fullScreen
                    self.present(navi, animated: false, completion: nil)
                }
            }
        case .complete:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.loadingIndicatorView.dismiss(animated: true)
            }
        case .error:
            DispatchQueue.main.async {
                self.loadingIndicatorView.isErrorOccurred = true
            }
        }
    }
    
    // MARK: - API Network calls
    
    /// Download photo data from API
    /// - Parameter albumId: AlbumId of the photo data belongs to
    private func getPhotos(albumId: Int) {
        if downloadTask == .start || downloadTask == .inProgress {
            return
        }
        downloadTask = .start
        if let selectedAlbum = self.album {
            let requestURL: String = Constants.URLs.BASEURL + Constants.APIs.PHOTO_ALBUM + String(selectedAlbum.id)
            DispatchQueue.global(qos: .userInitiated).async {
                APIService().fetchPhotosForAlbum(requestURL: requestURL, completionHandler: { [self] (getResponse:  () throws -> [Photo]) in
                    do {
                        let photos = try getResponse()
                        if photos.count > 0 {
                            self.photos = photos
                            self.downloadTask = .complete
                        } else {
                            DDLogError("func:getPhotos returns empty")
                            self.downloadTask = .error
                        }
                    } catch let error {
                        DDLogError("func:getPhotos #\(error)")
                        self.downloadTask = .error
                    }
                })
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == IMAGE_FULLSCREEN_SEGUE,
           let index = sender as? Int,
           let vc = segue.destination as? FullImageViewController {
            vc.photoData = self.photos[index]
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
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IMAGE_THUMB_CELL_IDENTIFIER, for: indexPath) as? PhotoThumbnailViewCell, self.photos.count > 0 {
            cell.photoData = photos[indexPath.row]
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: IMAGE_FULLSCREEN_SEGUE, sender: indexPath.row)
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

