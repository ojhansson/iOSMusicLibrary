struct TopAlbum: Codable {
    let loved: [Loved]
}

struct Loved: Codable {
    let idAlbum: String
    let strAlbum : String
    let strArtist: String
    let strAlbumThumb: String?
    let intYearReleased: String
}
    
    

