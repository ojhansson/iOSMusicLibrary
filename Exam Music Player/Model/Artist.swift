import Foundation

struct Artist: Codable {
    let artists: [Artists]
}

struct Artists: Codable {
    let strArtist: String
    let strArtistThumb: String?
}
