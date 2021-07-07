//
//  ImageCenter.swift
//
//  Created by David Casserly on 18/11/2015.
//  Copyright © 2015 DevedUp Ltd. All rights reserved.
//

import UIKit

enum ImageLoadError: Error {
    case couldNotConstructImage
}

public enum Priority {
    case low
    case normal
    case high
    
    var queuePriority: Float {
        switch self {
        case .low:
            return URLSessionDataTask.lowPriority
        case .normal:
            return URLSessionDataTask.defaultPriority
        case .high:
            return URLSessionDataTask.highPriority
        }
    }
}

public struct ImageAndURL {
    public let image: UIImage
    public let url: URL
}

public class ImageCenter {
	
    public static var debug: Bool = false
    static var diskCache: Cache = DefaultDiskCache()
	static var memoryCache: Cache = DefaultMemoryCache()
    
	private static var imageDownloadQueue: OperationQueue = {
		var queue = OperationQueue()
		queue.name = "Image download queue"
		queue.maxConcurrentOperationCount = 5
		return queue
	}()
	
	private static var imageCacheCheckQueue: OperationQueue = {
		var queue = OperationQueue()
		queue.name = "Image cache check queue"
		queue.maxConcurrentOperationCount = 20
		return queue
	}()
    
    /// Clear the caches
    public class func clearCache() {
        ImageCenter.diskCache.clearCache()
        ImageCenter.memoryCache.clearCache()
    }
	
    /**
    If image is in the cache return it immediately, otherwise it will come back in the completion block
	
    - parameter url:        url of the image
    - parameter completion: the completion block with the imag
	
    - returns: an operation which can be cancelled, or contains image from cache
    */
    @discardableResult
    public class func imageForURL(_ url: URL, httpHeaders: [String: String] = [:], priority: Priority = .normal, onImageLoad: @escaping (Result<ImageAndURL, Error>) -> Void) -> DownloadOperation {
        let imageOperation = DownloadOperation(url: url, httpHeaders: httpHeaders) { (result) in
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    let cacheKey = url.cacheKey()
                    _ = self.memoryCache.storeData(data, forKey: cacheKey)
                    _ = self.diskCache.storeData(data, forKey: cacheKey)
                    onImageLoad(.success(ImageAndURL(image: image, url: url)))
                } else {
                    onImageLoad(.failure(ImageLoadError.couldNotConstructImage))
                }
            case .failure(let error):
                onImageLoad(.failure(error))
            }
        }
            
		let cacheCheck = BlockOperation { () -> Void in
			if let cachedImageData = ImageCenter.imageDataFromCache(url) {
                DispatchQueue.global(qos: .default).async {
                    if let image = UIImage(data: cachedImageData) {
                        DispatchQueue.main.async(execute: { () -> Void in
                            onImageLoad(.success(ImageAndURL(image: image, url: url)))
                        })
                    }
                }
			} else {
				imageDownloadQueue.addOperation(imageOperation)
			}
		}
		imageCacheCheckQueue.addOperation(cacheCheck)
		
		return imageOperation
	}
	
	private class func imageDataFromCache(_ url: URL) -> Data? {
        let key = url.cacheKey()
		if let cachedData = ImageCenter.memoryCache.dataForKey(key) {
            noThrillDebug("Loaded image from memory cache \(url.absoluteString)")
			return cachedData
		} else if let cachedData = ImageCenter.diskCache.dataForKey(key) {
            noThrillDebug("Loaded image from disk cache 2 \(url.absoluteString)")
            // Put it into the memory cache
            _ = ImageCenter.memoryCache.storeData(cachedData, forKey: key)            
			return cachedData
		} else {
			return nil
		}
	}
    
    /**
     Cancel all pending image load operations
     */
    class func cancelAllImageOperations() {
        imageDownloadQueue.cancelAllOperations()
    }
		
}

func noThrillDebug(_ message: String) {
    //if (ImageCenter.debug) {
        print(message)
    //}
}
