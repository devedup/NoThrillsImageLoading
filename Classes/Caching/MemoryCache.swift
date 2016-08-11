//
//  MemoryCache.swift
//  NoThrillsImageLoading
//
//  Created by David Casserly on 03/12/2015.
//  Copyright © 2015 DevedUpLtd. All rights reserved.
//

import UIKit
import Foundation

class DefaultMemoryCache: CacheProtocol {
	
	private let cache = NSCache<AnyObject, AnyObject>()
	
	init() {
	}
	
	func storeData(_ data: Data, forKey key: String) {
		self.cache.setObject(data, forKey: key)
	}
	
	
	func dataForKey(_ key: String) -> Data? {
		return self.cache.object(forKey: key) as? Data
	}
	
	func clearCache() {
		self.cache.removeAllObjects()
	}
}
