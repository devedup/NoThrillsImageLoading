//
//  MemoryCache.swift
//  NoThrillsImageLoading
//
//  Created by David Casserly on 03/12/2015.
//  Copyright © 2015 DevedUpLtd. All rights reserved.
//

import UIKit

class DefaultMemoryCache: Cache {
	
	private let cache: NSCache
	
	init() {
		cache = NSCache()
	}
	
	func storeData(data: NSData, forKey key: String) {
		cache.setObject(data, forKey: key)
	}
	
	
	func dataForKey(key: String) -> NSData? {
		return cache.objectForKey(key) as? NSData
	}
	
	func clearCache() {
		cache.removeAllObjects()
	}
}