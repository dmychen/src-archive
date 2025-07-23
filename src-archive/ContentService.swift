//
//  ContentService.swift
//  src-archive
//
//  Created by Daniel Chen on 7/23/25.
//

import Foundation

// MARK: - singleton service to fetch content metadata, for now we simulate with mock data
class ContentService {
    static let shared = ContentService()
    
    private init() {}
    
    func fetchUserContent(completion: @escaping (Result<[ContentMetadata], Error>) -> Void) {
        // FIXME: replace with real API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let mockData = self.generateMockData()
            completion(.success(mockData))
        }
    }
    
    private func generateMockData() -> [ContentMetadata] {
        var data = [
            ContentMetadata(
                userPostID: "1", userID: "user1", postType: "image", postUUID: "uuid1",
                postDescription: "Beautiful sunset", locationGridMapID: nil,
                resolutionHeight: "1080", resolutionWidth: "1080",
                postLocalTime: "2024-01-15T18:30:00", postServerTime: "2024-01-15T18:30:00",
                username: "photographer1", profilePicUUID: "pic1",
                profileDescription: "Nature lover", profileAlbumID: "album1",
                pop: "85", numComments: 12, graffitiS3URL: nil,
                graffitiResHeight: nil, graffitiResWidth: nil, graffitiArtists: nil
            ),
            ContentMetadata(
                userPostID: "2", userID: "user2", postType: "video", postUUID: "uuid2",
                postDescription: "Street art timelapse", locationGridMapID: "grid1",
                resolutionHeight: "1920", resolutionWidth: "1080",
                postLocalTime: "2024-01-14T12:15:00", postServerTime: "2024-01-14T12:15:00",
                username: "artist2", profilePicUUID: "pic2",
                profileDescription: "Urban artist", profileAlbumID: "album2",
                pop: "92", numComments: 25, graffitiS3URL: "https://example.com/graffiti.jpg",
                graffitiResHeight: "1080", graffitiResWidth: "1080", graffitiArtists: ["Artist1", "Artist2"]
            ),
            ContentMetadata(
                userPostID: "3", userID: "user3", postType: "image", postUUID: "uuid3",
                postDescription: "City architecture", locationGridMapID: "grid2",
                resolutionHeight: "1080", resolutionWidth: "1080",
                postLocalTime: "2024-01-13T09:45:00", postServerTime: "2024-01-13T09:45:00",
                username: "architect3", profilePicUUID: "pic3",
                profileDescription: "Building enthusiast", profileAlbumID: "album3",
                pop: "78", numComments: 8, graffitiS3URL: nil,
                graffitiResHeight: nil, graffitiResWidth: nil, graffitiArtists: nil
            )
        ]
        
        // fill in rest of grid with more cells
        for i in 4...25 {
            data.append(ContentMetadata(
                userPostID: "\(i)", userID: "user\(i)", postType: i % 3 == 0 ? "video" : "image",
                postUUID: "uuid\(i)", postDescription: "Sample post \(i)",
                locationGridMapID: nil, resolutionHeight: "1080", resolutionWidth: "1080",
                postLocalTime: "2024-01-\(10 + i % 20)T\(10 + i % 12):00:00",
                postServerTime: "2024-01-\(10 + i % 20)T\(10 + i % 12):00:00",
                username: "user\(i)", profilePicUUID: "pic\(i)",
                profileDescription: "Sample user", profileAlbumID: "album\(i)",
                pop: "\(60 + i % 40)", numComments: i % 20, graffitiS3URL: nil,
                graffitiResHeight: nil, graffitiResWidth: nil, graffitiArtists: nil
            ))
        }
        
        return data
    }
}
