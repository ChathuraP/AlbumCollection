# AlbumCollection

## About The Project
This project is a sample for downloading a list of albums and artists from the `jsonplaceholder.typicode.com` server and then displaying it as a list. Upon tapping on a single album, it will open a collection of thumbnail images that belong to the album. Furthermore, upon tapping on a thumbnail, it will download the full image and open in a separate view with zoom capability.

## Getting Started

### Prerequisites
* MacBook with XCode 13
* Cocoapod installed
* Internet connection

### Installation
1. Clone the repo
   ```sh
   git clone https://github.com/ChathuraP/AlbumCollection.git
   ```
2. Use mac terminal and locate to the repo, then run 
   ```sh
   pod install
   ```
3. Open the repo folder and open the `Albums.xcworkspace` in XCode.
4. Select a simulator and run.

### Resources
* [list of albums](https://jsonplaceholder.typicode.com/albums)
* [list of artists](https://jsonplaceholder.typicode.com/users)
* [list of thumbnail](https://jsonplaceholder.typicode.com/photos)

### Assumptions/decisions
* The app compiles and runs on XCode 13.3 and Swift 5 or higher.
* run on iOS 15 simulator or higher.
* API will return at least one album.
* Internet connectivity is available.
* Only iPhones and iPhone simulators are supported.
* The device orientation is portrait.
* While downloading resources, the user does not cause the app to go to the background.
* The user does not receive or answer calls while the app is used.
* Unit test coverage is not completed.


