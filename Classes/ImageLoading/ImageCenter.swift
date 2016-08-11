//
//  ImageCenter.swift
//
//  Created by David Casserly on 18/11/2015.
//  Copyright © 2015 DevedUp Ltd. All rights reserved.
//

import UIKit

public class ImageCenter {
	
    static var diskCache: CacheProtocol = DefaultDiskCache()
	static var memoryCache: CacheProtocol = DefaultMemoryCache()
	
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
	public class func imageForURL(_ url: URL, onImageLoad: (UIImage?, URL) -> Void) -> ImageLoadOperation {
		
		let imageOperation = ImageLoadOperation(url: url, diskCache: diskCache, memoryCache: memoryCache, onImageLoad: onImageLoad)
		
		let cacheCheck = BlockOperation { () -> Void in
			if let cachedImageData = ImageCenter.imageDataFromCache(url) {
				DispatchQueue.global().async(execute: {
					if let image = UIImage(data: cachedImageData) {
						DispatchQueue.main.async(execute: { () -> Void in
							onImageLoad(image, url)
						})
					}
				})
			} else {
				imageDownloadQueue.addOperation(imageOperation)
			}
		}
		imageCacheCheckQueue.addOperation(cacheCheck)
		
		return imageOperation
	}
	
	private class func imageDataFromCache(_ url: URL) -> Data? {
		if let cachedData = ImageCenter.memoryCache.dataForKey(url.cacheKey()) {
			return cachedData
		} else if let cachedData = ImageCenter.diskCache.dataForKey(url.cacheKey()) {
			return cachedData
		} else {
			return nil
		}
	}
    
    /**
     Cancell all pending image load operations
     */
    class func cancelAllImageOperations() {
        imageDownloadQueue.cancelAllOperations()
    }
		
}

public class ImageLoadOperation: Operation {
		
	private let onImageLoad: (UIImage?, URL) -> Void
	private let url: URL
    private let diskCache: CacheProtocol
	private let memoryCache: CacheProtocol
	private let cacheKey: String
	
	init(url: URL, diskCache: CacheProtocol, memoryCache: CacheProtocol, onImageLoad: (UIImage?, URL) -> Void) {
		self.onImageLoad = onImageLoad
		self.url = url
        self.diskCache = diskCache
		self.memoryCache = memoryCache
		self.cacheKey = url.cacheKey()
	}
	
	public override func main() {
		// Wrap the completion block to ensure dispatched to main queue and not have dispatch_async blocks
		// literring this method
		let imageLoadCompletion: (UIImage?) -> Void = { (image) -> Void in
			DispatchQueue.main.async(execute: { () -> Void in
				self.onImageLoad(image, self.url)
			})
		}
		
		guard !self.isCancelled else {
			imageLoadCompletion(nil)
			return
		}
		
		// First check memory cache
		/*
		if let cachedImage = memoryCache.dataForKey(cacheKey) {
			if let image = UIImage(data: cachedImage) {
				imageLoadCompletion(image)
				return
			}
		}
		
		// Then check disk cache
		if let cachedImage = diskCache.dataForKey(cacheKey) {
			if let image = UIImage(data: cachedImage) {
				imageLoadCompletion(image)
				return
			}
		}
		*/
		
		// Now try the network
		print("Loading image from network from \(self.url.absoluteString)")
		if let data = try? Data(contentsOf: url, options: Data.ReadingOptions.uncached) {
            guard !self.isCancelled else {
				imageLoadCompletion(nil)
                return
            }
            
			if let image = UIImage(data: data) {
				print("Completed loading image from network from \(self.url.absoluteString)")
				diskCache.storeData(data, forKey: cacheKey)
				memoryCache.storeData(data, forKey: cacheKey)
				imageLoadCompletion(image)
            } else {
				imageLoadCompletion(nil)
            }
		}
	}
	
}
