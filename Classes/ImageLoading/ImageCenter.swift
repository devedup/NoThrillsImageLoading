//
//  ImageCenter.swift
//
//  Created by David Casserly on 18/11/2015.
//  Copyright © 2015 DevedUp Ltd. All rights reserved.
//

import UIKit

public class ImageCenter {
	
    static var cache: DiskCache = DefaultDiskCache()
    
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
	public class func imageForURL(url: NSURL, onImageLoad: (UIImage?, NSURL) -> Void) -> ImageLoadOperation? {
        // First check the cache
        let cacheKey = url.cacheKey()
        if let cachedImage = cache.dataForKey(cacheKey) {
            if let image = UIImage(data: cachedImage) {
                onImageLoad(image, url)
                return nil
            }
        }
        
		let imageOperation = ImageLoadOperation(url: url, cache: cache, onImageLoad: onImageLoad)
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
    private let cache: DiskCache
	private let cacheKey: String
	
    init(url: NSURL, cache: DiskCache, onImageLoad: (UIImage?, NSURL) -> Void) {
		self.onImageLoad = onImageLoad
		self.url = url
        self.cache = cache
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
		
		print("Loading image from network from \(self.url.absoluteString)")
		if let data = try? NSData(contentsOfURL: url, options: NSDataReadingOptions.DataReadingUncached) {
            guard !self.cancelled else {
				imageLoadCompletion(nil)
                return
            }
            
			if let image = UIImage(data: data) {
				print("Completed loading image from network from \(self.url.absoluteString)")
				cache.storeData(data, forKey: cacheKey)
				imageLoadCompletion(image)
            } else {
				imageLoadCompletion(nil)
            }
		}
	}
	
}