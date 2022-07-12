//
//  ViewController.swift
//  Albums
//
//  Created by Chathura Palihakkara on 9/7/22.
// jsonplaceholder.typicode.com/albums?id=1&id=4

import UIKit
import CocoaLumberjack

class AlbumListViewController: UIViewController {
    
    @IBOutlet weak var albumTableView: UITableView!
    @IBOutlet weak var reloadAlbumsView: UIView!
    private let refreshControl = UIRefreshControl()
    
    private var albums: [Album] = [] {
        didSet {
            DispatchQueue.main.async {
                if self.albums.count > 0 {
                    self.reloadAlbumsView.isHidden = true
                    self.refreshControl.endRefreshing()
                    self.albumTableView.reloadData()
                } else {
                    self.reloadAlbumsView.isHidden = false
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
    private var downloadAlbumInprogress: Bool = false
    private var downloadArtistsInprogress: Bool = false
    
    // MARK: - LifeCycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addRefreshController()
        self.getAlbums(albumIndex: 0, offset: downloadOffset)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - User Actions
    @IBAction func reloadAlbums(_ sender: UIButton) {
        self.albums.removeAll()
        self.artists.removeAll()
        self.tempAlbums.removeAll()
        lastFetchBlockSize = 1
        self.getAlbums(albumIndex: 0, offset: downloadOffset)
    }
    
    @IBAction func testBtnPressed(_ sender: UIButton) {

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
        albums = albums + newAlbums // append album list with new albums
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
        if downloadAlbumInprogress {
            return
        }
        downloadAlbumInprogress = true
        let requestString: String = Constants.APIs.albumRange + self.generateRequestStringForAlbums(start: albumIndex, offset: offset)
        DispatchQueue.global(qos: .default).async {
            APIService.shared.fetchAlbums(requestString: requestString, completionHandler: { [self] (getResponse:  () throws -> [Album]) in
                do {
                    let albums = try getResponse()
                    self.updateNewAlbums(albums)
                    self.downloadAlbumInprogress = false
                } catch let error {
                    //                    self.reloadAlbumsView.isHidden = false
                    DDLogError("func:getAlbums #\(error)")
                }
            })
        }
    }
    
    private func getArtists(artists: [Int]) {
        if downloadArtistsInprogress {
            return
        }
        downloadArtistsInprogress = true
        let requestString: String = Constants.APIs.userRange + self.generateRequestStringForArtists(artists)
        DispatchQueue.global(qos: .default).async {
            APIService.shared.fetchUsers(requestString: requestString, completionHandler: { [self] (getResponse:  () throws -> [Int : User]) in
                do {
                    let artists = try getResponse()
                    self.updateAlbumsWith(users: artists)
                    downloadArtistsInprogress = false
                } catch let error {
                    DDLogError("func:getArtists #\(error)")
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
