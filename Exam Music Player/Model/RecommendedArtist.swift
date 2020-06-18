import Foundation

struct RecommendedArtist: Codable {
    let similar: Similar
    private enum CodingKeys: String, CodingKey{
        case similar = "Similar"
    }
}

struct Similar: Codable {
    let results: [Results]
    private enum CodingKeys: String, CodingKey{
        case results = "Results"
    }
}

struct Results: Codable {
    let name: String
    let mediaType: String
    private enum CodingKeys: String, CodingKey{
        case name = "Name"
        case mediaType = "Type"
    }
}
