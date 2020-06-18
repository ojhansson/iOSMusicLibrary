import Foundation

struct AlbumTrack: Codable {
    let track: [Track]
}

struct Track: Codable {
    let idTrack: String
    let idAlbum: String
    let intDuration: String
    let strTrack: String
    let strAlbum : String
    let strArtist: String
    let strAlbumThumb: String?
}
