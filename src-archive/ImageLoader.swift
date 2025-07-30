//
//  ImageLoader.swift
//  src-archive
//
//  Created by Daniel Chen on 7/23/25.
//

import UIKit
import ObjectiveC

class ImageLoader {
    static let shared = ImageLoader()
    
    private let cache = NSCache<NSString, UIImage>()
    private let session = URLSession.shared
    
    private init() {
        cache.countLimit = 100 // limit cache to 100 images
    }
    
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("ImageLoader: Invalid URL format: \(urlString)")
            completion(nil)
            return
        }
        
        // Check cache first
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }
        
        // Load from network
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("ImageLoader: Network error for \(urlString): \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        print("ImageLoader: HTTP error status \(httpResponse.statusCode) for \(urlString)")
                        completion(nil)
                        return
                    }
                }
                
                guard let data = data else {
                    print("ImageLoader: No data received for \(urlString)")
                    completion(nil)
                    return
                }
                
                guard let image = UIImage(data: data) else {
                    print("ImageLoader: Failed to create UIImage from data for \(urlString)")
                    completion(nil)
                    return
                }
                
                // Cache the image
                self?.cache.setObject(image, forKey: urlString as NSString)
                completion(image)
            }
        }
        task.resume()
    }
    
    func cancelLoad(for urlString: String) {
        // TODO: implement cancellation of a specific taskk
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}

// MARK: - extension to UIImageView to load images through cloudfrontURL
extension UIImageView {
    private static var imageLoadTaskKey: UInt8 = 0
    
    private var imageLoadTask: URLSessionDataTask? {
        get {
            return objc_getAssociatedObject(self, &UIImageView.imageLoadTaskKey) as? URLSessionDataTask
        }
        set {
            objc_setAssociatedObject(self, &UIImageView.imageLoadTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func loadImage(from urlString: String, placeholder: UIImage? = nil) {
        // cancel any existing load task
        if let existingTask = imageLoadTask {
            existingTask.cancel()
        }
        
        // Set placeholder
        self.image = placeholder
        
        // Load image using the shared loader
        ImageLoader.shared.loadImage(from: urlString) { [weak self] image in
            guard let self = self else { return }
            
            if let image = image {
                self.image = image
            }
        }
    }
}

