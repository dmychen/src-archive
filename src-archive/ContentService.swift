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
    
    func fetchUserContent(page: Int, pageSize: Int, completion: @escaping (Result<[ContentMetadata], Error>) -> Void) {
        // load mock data
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let mockData = try self.loadMockDataFromJSON()
                DispatchQueue.main.async {
                    completion(.success(mockData))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // loading data from test_metadata.kson for now
    private func loadMockDataFromJSON() throws -> [ContentMetadata] {
        guard let url = Bundle.main.url(forResource: "test_metadata", withExtension: "json") else {
            throw ContentServiceError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let response = try decoder.decode(getContentMetadataResponseBodyV2.self, from: data)
        
        return response.contentMetadata
    }
}

// MARK: - Error types
enum ContentServiceError: Error, LocalizedError {
    case fileNotFound
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "test_metadata.json file not found in bundle"
        }
    }
}
