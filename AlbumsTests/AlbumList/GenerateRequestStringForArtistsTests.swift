//
//  GenerateRequestStringForArtistsTests.swift
//  AlbumsTests
//
//  Created by Chathura Palihakkara on 9/7/22.
//

import XCTest
@testable import Albums

class GenerateRequestStringForArtistsTests: XCTestCase {

    var albumList: AlbumListViewController? = nil
    
    override func setUpWithError() throws {
        albumList = AlbumListViewController()
    }

    override func tearDownWithError() throws {
        albumList = nil
    }
    
    func testGenerateRequestStringForArtistsWithMinusIntArray() {
        let users = [-3,-4,-5,-6]
        XCTAssertEqual(albumList?.generateRequestStringForArtists(users), "")
    }
    
    func testGenerateRequestStringForArtistsWithMixedIntArray() {
        let users = [0,4,-5,0]
        XCTAssertEqual(albumList?.generateRequestStringForArtists(users), "")
    }
    
    func testGenerateRequestStringForArtistsWillPlusIntArray() {
        let users = [3,4,5,6]
        XCTAssertEqual(albumList?.generateRequestStringForArtists(users), "id=3&id=4&id=5&id=6")
    }


}
