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

public class ImageCenter {
	
    public static var debug: Bool = true
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
	
    /**
    If image is in the cache return it immediately, otherwise it will come back in the completion block
	
    - parameter url:        url of the image
    - parameter completion: the completion block with the imag
	
    - returns: an operation which can be cancelled, or contains image from cache
    */
    @discardableResult
	public class func imageForURL(_ url: URL, httpHeaders: [String: String] = [:], onImageLoad: @escaping (Result<(UIImage, URL), Error>) -> Void) -> DownloadOperation {
        let imageOperation = DownloadOperation(url: url, httpHeaders: httpHeaders) { (result) in
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    let cacheKey = url.cacheKey()
                    self.memoryCache.storeData(data, forKey: cacheKey)
                    self.diskCache.storeData(data, forKey: cacheKey)
                    onImageLoad(.success((image, url)))
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
                            onImageLoad(.success((image, url)))
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
            ImageCenter.memoryCache.storeData(cachedData, forKey: key)            
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
    if (ImageCenter.debug) {
        print(message)
    }
}
