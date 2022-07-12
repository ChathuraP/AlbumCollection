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
    private var downloadInprogress: Bool = false {
        didSet {
            self.showDownloadIncicator(self.downloadInprogress)
        }
    }
    private var photos: [Photo] = [] {
        didSet {
            if self.photos.count > 0 {
                self.collectionView.reloadData()
            }
        }
    }
    
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
    
    func retryButtonTapped() {
        if let photoAlbum = album,
            photoAlbum.id != -1 {
            self.getPhotos(albumId: photoAlbum.id)
        }
    }
    
    private func showDownloadIncicator(_ show: Bool) {
        DispatchQueue.main.async {
            if show {
                if self.loadingIndicatorView.viewIfLoaded?.window == nil {
                    self.loadingIndicatorView.delegate = self
                    let navi = UINavigationController(rootViewController: self.loadingIndicatorView)
                    navi.modalPresentationStyle = .fullScreen
                    self.present(navi, animated: false, completion: nil)
                }
            } else {
                if self.loadingIndicatorView.viewIfLoaded?.window != nil {
                    if !self.loadingIndicatorView.errorOccurred {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.loadingIndicatorView.dismiss(animated: true)
                        }
                    }
                }
            }
        }
    }
        
    // MARK: - API Network calls
    private func getPhotos(albumId: Int) {
        if downloadInprogress {
            return
        }
        downloadInprogress = true
        if let selectedAlbum = self.album {
            let requestURL: String = Constants.URLs.baseURL + Constants.APIs.photoAlbum + String(selectedAlbum.id)
            DispatchQueue.global(qos: .userInitiated).async {
                APIService().fetchPhotosForAlbum(requestURL: requestURL, completionHandler: { [self] (getResponse:  () throws -> [Photo]) in
                    do {
                        let photos = try getResponse()
                        self.photos = photos
                        self.downloadInprogress = false
                    } catch let error {
                        DDLogError("func:getPhotos #\(error)")
                        self.loadingIndicatorView.errorOccurred = true
                        self.downloadInprogress = false
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

