//
//  ViewController.swift
//  Albums
//
//  Created by Chathura Palihakkara on 9/7/22.
// jsonplaceholder.typicode.com/albums?id=1&id=4

import UIKit
import CocoaLumberjack

class AlbumListViewController: UIViewController, LoadingViewDelegate {
    
    @IBOutlet weak var albumTableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    private var loadingIndicatorView = LoadingViewController()
    private var firstDownload: Bool = true
    private var albums: [Album] = [] {
        didSet {
            DispatchQueue.main.async {
                if self.albums.count > 0 {
                    self.albumTableView.reloadData()
                }
            }
        }
    }
    private var artists: [Int : User] = [:]
    
    private let PHOTO_GALLERY_SEGUE = "photoGallerySegue"
    private let ALBUM_CELL_IDENTIFIER = "AlbumCellIdentifier"
    
    // used for creating pagination on album retrieval
    private var tempAlbums: [Album] = []
    private var lastAlbumId: Int = 0
    private var downloadBuffer: Int = 5
    private var downloadOffset: Int = 19
    private var lastFetchBlockSize: Int = 1
    private var apiFailed: Bool = false
    private var downloadInProgress: Bool = false {
        didSet {
            self.showDownloadIndicator(self.downloadInProgress)
        }
    }
    
    // MARK: - LifeCycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addRefreshController()
        self.reloadAlbums(nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - User Actions
    
    /// Reload Album data from beginning
    /// - Parameter sender: UIButton or nil
    @IBAction func reloadAlbums(_ sender: UIButton?) {
        albums.removeAll()
        artists.removeAll()
        tempAlbums.removeAll()
        firstDownload = true
        apiFailed = false
        lastFetchBlockSize = 1
        getAlbums(albumIndex: 0, offset: downloadOffset)
    }

    // MARK: - LoadingViewDelegate function
    
    /// Triggers from Loading Error screen re-try button
    func retryButtonTapped() {
        self.reloadAlbums(nil)
    }

    // MARK: - Private functions
    
    /// Add pull to refresh functionality to the album list
    private func addRefreshController() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 20),
            .foregroundColor: UIColor.systemYellow,
        ]
        refreshControl.attributedTitle = NSAttributedString(string: Constants.Text.PULLTOREFRESH, attributes: attributes)
        refreshControl.tintColor = UIColor.systemYellow
        refreshControl.addTarget(self, action: #selector(self.reloadAlbums(_:)), for: .valueChanged)
        albumTableView.addSubview(refreshControl)
    }
    
    
    /// Show loading inProgress and Error re-try screens
    /// - Parameter show: Indicates download in progress or completed
    private func showDownloadIndicator(_ show: Bool) {
        if firstDownload { // show download progress only for the first album download session, since rest are pre-fetch
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
                        if self.apiFailed {
                            self.loadingIndicatorView.errorOccurred = true
                            self.firstDownload = true
                        } else {
                            self.firstDownload = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.loadingIndicatorView.dismiss(animated: true)
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.refreshControl.endRefreshing()
                        }
                    }
                }
            }
        }
    }
    
    
    /// Download artists data for already downloaded albums
    /// - Parameter albums: Downloaded albums
    private func fetchArtistForAlbums(_ albums: [Album]) {
        tempAlbums = albums
        lastFetchBlockSize = albums.count
        var requiredArtists: Set<Int> = [] // list to collect unique artist IDs to fetch artists
        for album in albums {
            if album.artist == nil && artists[album.userId] == nil {
                    requiredArtists.insert(album.userId) // if artist not downloaded before
            }
        }
        if requiredArtists.count > 0 {
            DispatchQueue.global(qos: .default).async {
                self.getArtists(artists: Array(requiredArtists)) // download artists
            }
        } else {
            self.updateAlbumsWith(users: [:])
        }
    }
    
    
    /// Update the existing albums with respective artists
    /// - Parameter users: Downloaded artists
    private func updateAlbumsWith(users: [Int : User]) {
        if users.count > 0 {
            artists.merge(users){(_, second) in second}
        }
        var newAlbums: [Album] = []
        for album in tempAlbums {
            var tempAlbum = album
            if let user = artists[tempAlbum.userId] {
                tempAlbum.updateArtist(With: user)
            }
            newAlbums.append(tempAlbum)
        }
        if newAlbums.count > 0 {
            albums = albums + newAlbums // append album list with new albums
        }
        lastAlbumId = albums.last?.id ?? 0
        tempAlbums.removeAll()
    }
    
    
    /// Generate request string for required albums
    /// - Parameters:
    ///   - start: Starting album id
    ///   - offset: How many albums needs to download
    /// - Returns: String to use for GET call parameters. ex: "id=0&id=1&id=2&id=3&id=4&id=5"
    internal func generateRequestStringForAlbums(start: Int, offset: Int) -> String {
        if start < 0 || offset < 0 {
            return ""
        }
        let end = start + offset
        var requestString: String = ""
        for id in (start ... end) {
            if requestString.isEmpty {
                requestString += "id=\(id)"
            } else {
                requestString += "&id=\(id)"
            }
        }
        return requestString
    }
    
    
    /// Generate request string for required artists
    /// - Parameter artists: Integer array of artist ids
    /// - Returns: String to use for GET call parameters. ex: "id=3&id=4&id=5&id=6"
    internal func generateRequestStringForArtists(_ artists: [Int]) -> String {
        if artists.contains(where: { $0 < 0 }) {
            return ""
        }
        var requestString: String = ""
        for id in artists {
            if requestString.isEmpty {
                requestString += "id=\(id)"
            } else {
                requestString += "&id=\(id)"
            }
        }
        return requestString
    }
    
    // MARK: - API Network calls
    
    /// Download albums from API
    /// - Parameters:
    ///   - albumIndex: Starting album id
    ///   - offset: How many albums needs to download
    private func getAlbums(albumIndex: Int, offset: Int) {
        if downloadInProgress {
            return
        }
        downloadInProgress = true
        let requestString: String = Constants.APIs.ALBUM_RANGE + self.generateRequestStringForAlbums(start: albumIndex, offset: offset)
        DispatchQueue.global(qos: .default).async {
            APIService().fetchAlbums(requestString: requestString, completionHandler: { [self] (getResponse:  () throws -> [Album]) in
                do {
                    let albums = try getResponse()
                    self.downloadInProgress = false
                    self.fetchArtistForAlbums(albums)
                } catch let error {
                    DDLogError("func:getAlbums #\(error)")
                    self.apiFailed = true
                    self.downloadInProgress = false
                }
            })
        }
    }
    
    
    /// Download artists from API
    /// - Parameter artists: Integer array of artist ids
    private func getArtists(artists: [Int]) {
        if downloadInProgress {
            return
        }
        downloadInProgress = true
        let requestString: String = Constants.APIs.USER_RANGE + self.generateRequestStringForArtists(artists)
        DispatchQueue.global(qos: .default).async {
            APIService().fetchUsers(requestString: requestString, completionHandler: { [self] (getResponse:  () throws -> [Int : User]) in
                do {
                    let artists = try getResponse()
                    self.updateAlbumsWith(users: artists)
                    self.downloadInProgress = false
                } catch let error {
                    DDLogError("func:getArtists #\(error)")
                    self.downloadInProgress = false
                }
            })
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PHOTO_GALLERY_SEGUE,
           let index = sender as? Int,
            let vc = segue.destination as? PhotosCollectionViewController {
            vc.album = self.albums[index]
        }
        self.albumTableView.isUserInteractionEnabled = true
    }
}

extension AlbumListViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {

    // MARK: UITableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell: AlbumCell = tableView.dequeueReusableCell(withIdentifier: ALBUM_CELL_IDENTIFIER, for: indexPath) as? AlbumCell,
           self.albums.count > 0 {
            cell.album = self.albums[indexPath.row]
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDataSourcePrefetching Delegate
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if isTimeToFetch(for: indexPaths) {
            self.getAlbums(albumIndex: lastAlbumId + 1  , offset: downloadOffset)
        }
    }

    // MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.albumTableView.isUserInteractionEnabled = false
        performSegue(withIdentifier: PHOTO_GALLERY_SEGUE, sender: indexPath.row)
    }
    
    /// Decide when to initiate pre-fetch albums
    /// - Parameter indexPaths: requested indices by iOS
    /// - Returns: ready to pre-fetch status
    private func isTimeToFetch(for indexPaths: [IndexPath]) -> Bool {
        if lastFetchBlockSize == 0 {
            return false
        }
        for indexPath in indexPaths where indexPath.row >= albums.count - downloadBuffer {
            return true
        }
        return false
    }
    
}
