//
//  Cache.swift
//  NoThrillsImageLoading
//
//  Created by David Casserly on 03/12/2015.
//  Copyright © 2015 DevedUpLtd. All rights reserved.
//

import UIKit

protocol Cache {
	
	/**
	Store data in the cache
	
	- parameter data: the data you want to store
	- parameter key:  the key for the data
	*/
	func storeData(data: NSData, forKey key: String)
	
	/**
	Retrieve data from the cache
	
	- parameter key: the key for the data you want
	
	- returns: either the data or nil if it wasn't in the cache
	*/
	func dataForKey(key: String) -> NSData?
 
	/**
	Remove everything in the cache
	*/
	func clearCache()
}