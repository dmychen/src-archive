//
//  ContentHelpers.swift
//  src-archive
//
//  Created by Daniel Chen on 8/4/25.
//

func cloudfrontURLFormatter(userID: String, contentUUID: String, contentType: ContentType? = nil, assetCategory: MediaAssetCategory) -> String? {
    if assetCategory == .post {
        if contentType == .image {
            return "https://d2efywtjr3ai55.cloudfront.net/\(userID)/post/\(contentUUID)/og"
        } else if contentType == .video {
            return "https://d2efywtjr3ai55.cloudfront.net/\(userID)/post/\(contentUUID)/hls/og.m3u8"
        }
    } else if assetCategory == .profile_pic {
        return "https://d2efywtjr3ai55.cloudfront.net/\(userID)/profile_pic/\(contentUUID)/og"
    }
    
    print("error formatting cloudfront url")
    return nil
}

