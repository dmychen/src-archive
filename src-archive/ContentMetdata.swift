struct ContentMetadata: Decodable {
    let userPostID: String
    let userID: String
    let postType: String  // "image" or "video"
    let postUUID: String
    let postDescription: String
    let locationGridMapID: String?
    let resolutionHeight: String
    let resolutionWidth: String
    let postLocalTime: String
    let postServerTime: String
    let username: String
    let profilePicUUID: String
    let profileDescription: String
    let profileAlbumID: String
    let pop: String
    let numComments: Int?
    let graffitiS3URL: String?
    let graffitiResHeight: String?
    let graffitiResWidth: String?
    let graffitiArtists: [String]?
    
    enum CodingKeys: String, CodingKey {
        case userPostID = "userPostID"
        case userID = "userID"
        case postType = "postType"
        case postUUID = "postUUID"
        case postDescription = "postDescription"
        case locationGridMapID = "locationGridMapID"
        case resolutionHeight = "resolutionHeight"
        case resolutionWidth = "resolutionWidth"
        case postLocalTime = "postLocalTime"
        case postServerTime = "postServerTime"
        case username = "username"
        case profilePicUUID = "profilePicUUID"
        case profileDescription = "profileDescription"
        case profileAlbumID = "profileAlbumID"
        case pop = "pop"
        case numComments = "numComments"
        case graffitiS3URL = "graffitiS3URL"
        case graffitiResHeight = "graffitiResHeight"
        case graffitiResWidth = "graffitiResWidth"
        case graffitiArtists = "graffitiArtists"
    }
}

struct ContentMetadataResponse: Decodable {
    let contentMetadata: [ContentMetadata]
    
    enum CodingKeys: String, CodingKey {
        case contentMetadata = "contentMetadata"
    }
}
