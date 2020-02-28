//
//  ImageCenter.swift
//
//  Created by David Casserly on 18/11/2015.
//  Copyright © 2015 DevedUp Ltd. All rights reserved.
//

import UIKit

public class ImageCenter {
	
    public static var debug: Bool = true
    static var diskCache: Cache = DefaultDiskCache()
	static var memoryCache: Cache = DefaultMemoryCache()
    fileprivate static let urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default)
    
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
	public class func imageForURL(_ url: URL, httpHeaders: [String: String] = [:], onImageLoad: @escaping (UIImage?, URL, Error?) -> Void) -> ImageLoadOperation {
		
		let imageOperation = ImageLoadOperation(url: url, diskCache: diskCache, memoryCache: memoryCache, httpHeaders: httpHeaders, onImageLoad: onImageLoad)
		
		let cacheCheck = BlockOperation { () -> Void in
			if let cachedImageData = ImageCenter.imageDataFromCache(url) {
                DispatchQueue.global(qos: .default).async {
                    if let image = UIImage(data: cachedImageData) {
                        DispatchQueue.main.async(execute: { () -> Void in
                            onImageLoad(image, url, nil)
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

public class ImageLoadOperation: Operation {
		
	private let onImageLoad: (UIImage?, URL, Error?) -> Void
	private let url: URL
    private let diskCache: Cache
	private let memoryCache: Cache
	private let cacheKey: String
    private let httpHeaders: [String: String]
    private var imageLoadTask: URLSessionDataTask?
    
	init(url: URL, diskCache: Cache, memoryCache: Cache, httpHeaders: [String: String], onImageLoad: @escaping (UIImage?, URL, Error?) -> Void) {
		self.onImageLoad = onImageLoad
		self.url = url
        self.diskCache = diskCache
		self.memoryCache = memoryCache
        self.httpHeaders = httpHeaders
		self.cacheKey = url.cacheKey()
	}
    
    public override func cancel() {
        super.cancel()
        imageLoadTask?.cancel()
    }
	
	public override func main() {
		// Wrap the completion block to ensure dispatched to main queue and not have dispatch_async blocks
		// literring this method
		let imageLoadCompletion: (UIImage?, Error?) -> Void = { (image, error) -> Void in
			DispatchQueue.main.async(execute: { () -> Void in
				self.onImageLoad(image, self.url, error)
			})
		}
		
		guard !self.isCancelled else {
			imageLoadCompletion(nil, nil)
			return
		}

		noThrillDebug("Loading image from network from \(self.url.absoluteString)")
                
        let session = ImageCenter.urlSession
        var urlRequest = URLRequest(url: self.url)
        for (key, value) in httpHeaders {
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        
        imageLoadTask = session.dataTask(with: urlRequest) { (data, response, error) in
            guard !self.isCancelled else {
                imageLoadCompletion(nil, nil)
                self.imageLoadTask?.cancel()
                return
            }
            
            guard error == nil else {
                imageLoadCompletion(nil, error)
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                noThrillDebug("Loaded image from network \(self.url.absoluteString)")
                self.memoryCache.storeData(data, forKey: self.cacheKey)
                self.diskCache.storeData(data, forKey: self.cacheKey)
                imageLoadCompletion(image, nil)
            } else {
                imageLoadCompletion(nil, error)
                return
            }
        }
        imageLoadTask?.resume()
        
        if self.isCancelled {
            imageLoadCompletion(nil, nil)
            imageLoadTask?.cancel()
            return
        }
	}
	
}

func noThrillDebug(_ message: String) {
    if (ImageCenter.debug) {
        print(message)
    }
}
