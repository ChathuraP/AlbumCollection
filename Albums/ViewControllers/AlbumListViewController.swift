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
//    private var errorOccurredView = ErrorViewController()
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
    private var tempAlbums: [Album] = []
    
    private var lastAlbumId: Int = 0
    private var downloadBufffer: Int = 5
    private var downloadOffset: Int = 19
    private var lastFetchBlockSize: Int = 1
    private var downloadInprogress: Bool = false {
        didSet {
            self.showDownloadIncicator(self.downloadInprogress)
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
    @IBAction func reloadAlbums(_ sender: UIButton?) {
        albums.removeAll()
        artists.removeAll()
        tempAlbums.removeAll()
        firstDownload = true
        lastFetchBlockSize = 1
        getAlbums(albumIndex: 0, offset: downloadOffset)
    }
    
    @IBAction func testBtnPressed(_ sender: UIButton) {

    }

    // MARK: - LoadingViewDelegate function
    func retryButtonTapped() {
        self.loadingIndicatorView.dismiss(animated: true)
        self.reloadAlbums(nil)
    }

    // MARK: - Private functions
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
    
    private func showDownloadIncicator(_ show: Bool) {
        if firstDownload { // show donload progress only for the first download session since rest are prefetch
            DispatchQueue.main.async {
                if show {
                    if self.loadingIndicatorView.viewIfLoaded?.window == nil {
                        self.loadingIndicatorView.delegate = self
                        let navi = UINavigationController(rootViewController: self.loadingIndicatorView)
                        navi.modalPresentationStyle = .fullScreen
                        self.present(navi, animated: true, completion: nil)
                    }
                } else {
                    if self.loadingIndicatorView.viewIfLoaded?.window != nil {
                        if !self.loadingIndicatorView.errorOccurred {
                            self.loadingIndicatorView.dismiss(animated: true)
                        }
                        self.firstDownload = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.refreshControl.endRefreshing()
                        }
                    }
                }
            }
        }
    }
    
    private func updateNewAlbums(_ albums: [Album]) {
        tempAlbums = albums
        fetchArtistforAlbums(albums)
        lastFetchBlockSize = albums.count
        print("lastFetchBlockSize:\(lastFetchBlockSize)")
    }
    
    private func fetchArtistforAlbums(_ albums: [Album]) {
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
        if albums.count > 0 {
            albums = albums + newAlbums // append album list with new albums
        } else {
            albums = newAlbums // add new albums
        }
        lastAlbumId = albums.last?.id ?? 0
        tempAlbums.removeAll()
    }
    
    private func generateRequestStringForAlbums(start: Int, offset: Int) -> String {
        let end = start + offset
        var requestString: String = ""
        for id in (start ... end) {
            if requestString.isEmpty {
                requestString += "id=\(id)"
            } else {
                requestString += "&id=\(id)"
            }
        }
        print("Downloding albums:\(requestString)")
        return requestString
    }
    
    private func generateRequestStringForArtists(_ artists:[Int]) -> String {
        var requestString: String = ""
        for id in artists {
            if requestString.isEmpty {
                requestString += "id=\(id)"
            } else {
                requestString += "&id=\(id)"
            }
        }
        print("Downloding artists:\(requestString)")
        return requestString
    }
    
    // MARK: - API Network calls
    private func getAlbums(albumIndex: Int, offset: Int) {
        if downloadInprogress {
            return
        }
        downloadInprogress = true
        let requestString: String = Constants.APIs.albumRange + self.generateRequestStringForAlbums(start: albumIndex, offset: offset)
        DispatchQueue.global(qos: .default).async {
            APIService().fetchAlbums(requestString: requestString, completionHandler: { [self] (getResponse:  () throws -> [Album]) in
                do {
                    let albums = try getResponse()
                    self.downloadInprogress = false
                    self.updateNewAlbums(albums)
                } catch let error {
                    DDLogError("func:getAlbums #\(error)")
                    self.loadingIndicatorView.errorOccurred = true
                    self.downloadInprogress = false
                }
            })
        }
    }
    
    private func getArtists(artists: [Int]) {
        if downloadInprogress {
            return
        }
        downloadInprogress = true
        let requestString: String = Constants.APIs.userRange + self.generateRequestStringForArtists(artists)
        DispatchQueue.global(qos: .default).async {
            APIService().fetchUsers(requestString: requestString, completionHandler: { [self] (getResponse:  () throws -> [Int : User]) in
                do {
                    let artists = try getResponse()
                    self.updateAlbumsWith(users: artists)
                    self.downloadInprogress = false
                } catch let error {
                    DDLogError("func:getArtists #\(error)")
                    self.loadingIndicatorView.errorOccurred = true
                    self.downloadInprogress = false
                }
            })
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoGallerySegue",
           let index = sender as? Int,
            let vc = segue.destination as? PhotosCollectionViewController {
            vc.album = self.albums[index]
        }
    }
}

extension AlbumListViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {

    private func updateCellsWith(inIndexPaths: [IndexPath]) {
        DispatchQueue.main.async {
            self.albumTableView.reloadRows(at: inIndexPaths, with: .top)
        }
    }

    // MARK: UITableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell: AlbumCell = tableView.dequeueReusableCell(withIdentifier: "AlbumCellIdentifier", for: indexPath) as? AlbumCell,
           self.albums.count > 0 {
            cell.album = self.albums[indexPath.row]
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    // MARK: UITableView Delegate
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if isTimeToFetch(for: indexPaths) {
            self.getAlbums(albumIndex: lastAlbumId + 1  , offset: downloadOffset)
        }
    }
    
    private func isTimeToFetch(for indexPaths: [IndexPath]) -> Bool {
        if lastFetchBlockSize == 0 {
            return false
        }
        for indexPath in indexPaths where indexPath.row >= albums.count - downloadBufffer {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "photoGallerySegue", sender: indexPath.row)
    }

}
