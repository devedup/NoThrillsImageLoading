//
//  ImageCenter.swift
//
//  Created by David Casserly on 18/11/2015.
//  Copyright © 2015 DevedUp Ltd. All rights reserved.
//

import UIKit

class ImageCenter {

	private static let queue: dispatch_queue_t = {
		dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
	}()
	
	/**
	If image is in the cache return it immediately, otherwise it will come back in the completion block
	
	- parameter url:        url of the image
	- parameter completion: the completion block with the imag
	
	- returns: the image if retrieved from the cache
	*/
	func imageForURL(url: NSURL, onNetworkLoad: (UIImage) -> Void) -> UIImage? {
		let cacheKey = url.cacheKey()
		
		// Check the cache first
		let cache = DiskCache()
		if let cachedImage = cache.dataForKey(cacheKey) {
			if let image = UIImage(data: cachedImage) {
				return image
			}
		}
		
		dispatch_async(ImageCenter.queue) { () -> Void in
			if let data = try? NSData(contentsOfURL: url, options: NSDataReadingOptions.DataReadingUncached) {
				if let image = UIImage(data: data) {
					cache.storeData(data, forKey: cacheKey)
					onNetworkLoad(image)
				}
			}
		}
		
		return nil
	}
		
}
