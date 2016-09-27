//
//  MemoryCache.swift
//  NoThrillsImageLoading
//
//  Created by David Casserly on 03/12/2015.
//  Copyright © 2015 DevedUpLtd. All rights reserved.
//

import UIKit

class DefaultMemoryCache: Cache {
	
	fileprivate let cache: NSCache<AnyObject, AnyObject>
	
	init() {
		cache = NSCache()
	}
	
	func storeData(_ data: Data, forKey key: String) {
		cache.setObject(data as AnyObject, forKey: key as AnyObject)
	}
	
	
	func dataForKey(_ key: String) -> Data? {
		return cache.object(forKey: key as AnyObject) as? Data
	}
	
	func clearCache() {
		cache.removeAllObjects()
	}
}
