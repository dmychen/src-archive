enum ContentType: Decodable {
    case image
    case video
    
    var description: String {
        switch self {
        case .image:
            return "image"
        case .video:
            return "video"
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue.lowercased() {
        case "image":
            self = .image
        case "video":
            self = .video
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown ContentType: \(rawValue)")
        }
    }
    
    init?(rawString: String) {
        switch rawString.lowercased() {
        case "image":
            self = .image
        case "video":
            self = .video
        default:
            return nil
        }
    }
}

enum MediaAssetCategory {
    case post
    case profile_pic 
    case snap
    case graffiti
    case album
    
    var description: String {
        switch self {
        case .post:
            return "post"
        case .profile_pic:
            return "profile_pic"
        case .snap:
            return "snap"
        case .graffiti:
            return "graffiti"
        case .album:
            return "album"
        }
    }
}

func cloudfrontURLFormatter(userID: String, contentUUID: String, contentType: ContentType? = nil, assetCategory: MediaAssetCategory) -> String? {
    if assetCategory == .post {
        if contentType == .image {
            return "https://d2efywtjr3ai55.cloudfront.net/sample_data/\(userID)/post/\(contentUUID)/og"
        } else if contentType == .video {
            return "https://d2efywtjr3ai55.cloudfront.net/sample_data/\(userID)/post/\(contentUUID)/hls/og.m3u8"
        }
    } else if assetCategory == .profile_pic {
        return "https://d2efywtjr3ai55.cloudfront.net/sample_data/\(userID)/profile_pic/\(contentUUID)/og"
    }
    
    goggins("error formatting cloudfront url")
    return nil
}

