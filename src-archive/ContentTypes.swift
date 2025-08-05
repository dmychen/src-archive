//
//  ContentTypes.swift
//  src-archive
//
//  Created by Daniel Chen on 7/23/25.
//

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

