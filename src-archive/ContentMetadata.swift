struct getContentMetadataResponseBodyV2: Decodable {
    let contentMetadata: [ContentMetadata]
    
    enum CodingKeys: String, CodingKey {
        case contentMetadata
    }
}

struct ContentMetadata: Decodable {
    let userPostID: String
    let userID: String
    let postType: ContentType  // "image" or "video"
    let postUUID: String
    let postDescription: String
    let locationGridMapID: String? // deprecated
    let resolutionHeight: Double
    let resolutionWidth: Double
    let postLocalTime: String
    let postServerTime: String
    let username: String
    let profilePicUUID: String
    let profileDescription: String
    let profileAlbumID: String
    let pop: Float
    let numComments: Int?
    let graffitiS3URL: String?
    let graffitiResHeight: Double?
    let graffitiResWidth: Double?
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
