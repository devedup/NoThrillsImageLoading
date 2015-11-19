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
	class func imageForURL(url: NSURL, onCompletion: (image: UIImage?, cancelled: Bool) -> Void) -> (image: UIImage?, operation: ImageLoadOperation?) {
		let imageOperation = ImageLoadOperation(url: url, onCompletion: onCompletion)
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
	
	private let onCompletion: (image: UIImage?, cancelled: Bool) -> Void
	private let url: NSURL
	private let cache = DiskCache()
	private let cacheKey: String
	
	init(url: NSURL, onCompletion: (UIImage?, Bool) -> Void) {
		self.onCompletion = onCompletion
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
			onCompletion(image: nil, cancelled: true)
			return
		}
		guard self.image == nil else {
			return
		}
		
		print("Loading image from network from \(self.url.absoluteString)")
		if let data = try? NSData(contentsOfURL: url, options: NSDataReadingOptions.DataReadingUncached) {
			if (self.cancelled) {
				onCompletion(image: nil, cancelled: true)
				return
			}
			if let image = UIImage(data: data) {
				self.image = image
				print("Completed loading image from network from \(self.url.absoluteString)")
				cache.storeData(data, forKey: cacheKey)
				onCompletion(image: image, cancelled: false)
			}
		}
	}
	
}