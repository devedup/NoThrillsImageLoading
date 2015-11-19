//
//  ImageCenter.swift
//
//  Created by David Casserly on 18/11/2015.
//  Copyright © 2015 DevedUp Ltd. All rights reserved.
//

import UIKit

class ImageCenter {
	
	private static var imageDownloadQueue: NSOperationQueue = {
		var queue = NSOperationQueue()
		queue.name = "Image download queue"
		queue.maxConcurrentOperationCount = 3
		return queue
	}()
	
	
    /**
    If image is in the cache return it immediately, otherwise it will come back in the completion block
	
    - parameter url:        url of the image
    - parameter completion: the completion block with the imag
	
    - returns: an operation which can be cancelled, or contains image from cache
    */
	class func imageForURL(url: NSURL, onNetworkLoad: (UIImage) -> Void) -> (image: UIImage?, operation: ImageLoadOperation?) {
		let imageOperation = ImageLoadOperation(url: url, onNetworkLoad: onNetworkLoad)
		if (imageOperation.image != nil) {
			return (imageOperation.image, nil)
		} else {
			imageDownloadQueue.addOperation(imageOperation)
			return (nil, imageOperation)
		}
	}
		
}

class ImageLoadOperation: NSOperation {
	
	var image: UIImage?
	
	private let onNetworkLoad: (UIImage) -> Void
	private let url: NSURL
	private let cache = DiskCache()
	private let cacheKey: String
	
	init(url: NSURL, onNetworkLoad: (UIImage) -> Void) {
		self.onNetworkLoad = onNetworkLoad
		self.url = url
		self.cacheKey = url.cacheKey()
		if let cachedImage = cache.dataForKey(cacheKey) {
			if let image = UIImage(data: cachedImage) {
				 self.image = image
			}
		}
	}
	
	override func main() {
		guard !self.cancelled else {
			return
		}
		guard self.image == nil else {
			return
		}
		
		if let data = try? NSData(contentsOfURL: url, options: NSDataReadingOptions.DataReadingUncached) {
			if let image = UIImage(data: data) {
				self.image = image
				cache.storeData(data, forKey: cacheKey)
				onNetworkLoad(image)
			}
		}
	}
	
}