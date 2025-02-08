import Foundation

struct PhotoResult: Decodable {
    let id: String
    let height: Int
    let width: Int
    let createdAt: String
    let welcomeDescription: String?
    let photosUrl: UrlsResult
    let isLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case height
        case width
        case createdAt = "created_at"
        case welcomeDescription = "description"
        case photosUrl = "urls"
        case isLiked = "liked_by_user"
    }
}
