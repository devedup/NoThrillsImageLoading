//
//  ImageCenter.swift
//
//  Created by David Casserly on 18/11/2015.
//  Copyright © 2015 DevedUp Ltd. All rights reserved.
//

import UIKit

public class ImageCenter {
	
    static var diskCache: Cache = DefaultDiskCache()
	static var memoryCache: Cache = DefaultMemoryCache()
	
	private static var imageDownloadQueue: NSOperationQueue = {
		var queue = NSOperationQueue()
		queue.name = "Image download queue"
		queue.maxConcurrentOperationCount = 5
		return queue
	}()
	
    /**
    If image is in the cache return it immediately, otherwise it will come back in the completion block
	
    - parameter url:        url of the image
    - parameter completion: the completion block with the imag
	
    - returns: an operation which can be cancelled, or contains image from cache
    */
	public class func imageForURL(url: NSURL, onImageLoad: (UIImage?, NSURL) -> Void) -> ImageLoadOperation {
		let imageOperation = ImageLoadOperation(url: url, diskCache: diskCache, memoryCache: memoryCache, onImageLoad: onImageLoad)
        imageDownloadQueue.addOperation(imageOperation)
        return imageOperation
	}
    
    
    /**
     Cancell all pending image load operations
     */
    class func cancelAllImageOperations() {
        imageDownloadQueue.cancelAllOperations()
    }
		
}

public class ImageLoadOperation: NSOperation {
		
	private let onImageLoad: (UIImage?, NSURL) -> Void
	private let url: NSURL
    private let diskCache: Cache
	private let memoryCache: Cache
	private let cacheKey: String
	
	init(url: NSURL, diskCache: Cache, memoryCache: Cache, onImageLoad: (UIImage?, NSURL) -> Void) {
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
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.onImageLoad(image, self.url)
			})
		}
		
		guard !self.cancelled else {
			imageLoadCompletion(nil)
			return
		}
		
		// First check memory cache
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
		
		// Now try the network
		print("Loading image from network from \(self.url.absoluteString)")
		if let data = try? NSData(contentsOfURL: url, options: NSDataReadingOptions.DataReadingUncached) {
            guard !self.cancelled else {
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