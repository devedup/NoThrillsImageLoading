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
	public class func imageForURL(url: NSURL, onImageLoad: (UIImage?) -> Void) -> ImageLoadOperation? {
        // First check the cache
        let cacheKey = url.cacheKey()
        if let cachedImage = cache.dataForKey(cacheKey) {
            if let image = UIImage(data: cachedImage) {
                onImageLoad(image)
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
		
	private let onImageLoad: (UIImage?) -> Void
	private let url: NSURL
    private let cache: DiskCache
	private let cacheKey: String
	
    init(url: NSURL, cache: DiskCache, onImageLoad: (UIImage?) -> Void) {
		self.onImageLoad = onImageLoad
		self.url = url
        self.cache = cache
		self.cacheKey = url.cacheKey()
	}
	
	public override func main() {
		guard !self.cancelled else {
			onImageLoad(nil)
			return
		}
		
		print("Loading image from network from \(self.url.absoluteString)")
		if let data = try? NSData(contentsOfURL: url, options: NSDataReadingOptions.DataReadingUncached) {
            guard !self.cancelled else {
                onImageLoad(nil)
                return
            }
            
			if let image = UIImage(data: data) {
				print("Completed loading image from network from \(self.url.absoluteString)")
				cache.storeData(data, forKey: cacheKey)
				onImageLoad(image)
            } else {
                onImageLoad(nil)
            }
		}
	}
	
}