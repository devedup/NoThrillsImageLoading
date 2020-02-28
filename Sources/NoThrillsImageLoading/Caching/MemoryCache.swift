//
//  MemoryCache.swift
//  NoThrillsImageLoading
//
//  Created by David Casserly on 03/12/2015.
//  Copyright © 2015 DevedUpLtd. All rights reserved.
//
import Foundation

class DefaultMemoryCache: Cache {
	
    fileprivate let cache: NSCache<NSString, NSData>
	
	init() {
		cache = NSCache<NSString, NSData>()
	}
	
	func storeData(_ data: Data, forKey key: String) {
		cache.setObject(data as NSData, forKey: key as NSString)
	}
	
	
	func dataForKey(_ key: String) -> Data? {
		return cache.object(forKey: key as NSString) as Data?
	}
	
	func clearCache() {
		cache.removeAllObjects()
	}
}
