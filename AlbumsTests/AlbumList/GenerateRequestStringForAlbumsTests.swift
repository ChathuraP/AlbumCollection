//
//  GenerateRequestStringTests.swift
//  AlbumsTests
//
//  Created by Chathura Palihakkara on 9/7/22.
//

import XCTest
@testable import Albums

class GenerateRequestStringForAlbumsTests: XCTestCase {
    
    var albumList: AlbumListViewController? = nil
    
    override func setUpWithError() throws {
        albumList = AlbumListViewController()
    }

    override func tearDownWithError() throws {
        albumList = nil
    }
    
    func testGenerateRequestStringForAlbumsWithZeroStartIdAndZeroOffset() {
        let startID = 0, offset = 0
        XCTAssertEqual(albumList?.generateRequestStringForAlbums(start: startID, offset: offset), "id=0")
    }
    
    func testGenerateRequestStringForAlbumsWithZeroStartIdAndPlusOffset() {
        let startID = 0, offset = 5
        XCTAssertEqual(albumList?.generateRequestStringForAlbums(start: startID, offset: offset), "id=0&id=1&id=2&id=3&id=4&id=5")
    }
    
    func testGenerateRequestStringForAlbumsWithZeroStartIdAndMinusOffset() {
        let startID = 0, offset = -5
        XCTAssertEqual(albumList?.generateRequestStringForAlbums(start: startID, offset: offset), "")
    }
    
    func testGenerateRequestStringForAlbumsWithMinusStartIdAndZeroOffset() {
        let startID = -4, offset = 0
        XCTAssertEqual(albumList?.generateRequestStringForAlbums(start: startID, offset: offset), "")
    }
    
    func testGenerateRequestStringForAlbumsWithMinusStartIdAndPlusOffset() {
        let startID = -4, offset = 5
        XCTAssertEqual(albumList?.generateRequestStringForAlbums(start: startID, offset: offset), "")
    }
    
    func testGenerateRequestStringForAlbumsWithMinusStartIdAndMinusOffset() {
        let startID = -4, offset = -5
        XCTAssertEqual(albumList?.generateRequestStringForAlbums(start: startID, offset: offset), "")
    }
    
    func testGenerateRequestStringForAlbumsWithPlusStartIdAndZeroOffset() {
        let startID = 5, offset = 0
        XCTAssertEqual(albumList?.generateRequestStringForAlbums(start: startID, offset: offset), "id=5")
    }
    
    func testGenerateRequestStringForAlbumsWithPlusStartIdAndPlusOffset() {
        let startID = 5, offset = 5
        XCTAssertEqual(albumList?.generateRequestStringForAlbums(start: startID, offset: offset), "id=5&id=6&id=7&id=8&id=9&id=10")
    }
    
    func testGenerateRequestStringForAlbumsWithPlusStartIdAndMinusOffset() {
        let startID = 5, offset = -5
        XCTAssertEqual(albumList?.generateRequestStringForAlbums(start: startID, offset: offset), "")
    }

}
