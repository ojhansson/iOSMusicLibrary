import Foundation

struct SearchAlbum: Codable {
    let album: [Album]
}

struct Album: Codable {
    let idAlbum: String
    let strAlbum : String
    let strArtist: String
    let strAlbumThumb: String?
    let intYearReleased: String
}
