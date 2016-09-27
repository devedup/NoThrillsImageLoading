//
//  URLKey.swift
//
//  Created by David Casserly on 18/11/2015.
//  Copyright © 2015 DevedUp Ltd. All rights reserved.
//

import UIKit

extension URL {

	/**
	Get a cache key for this url
	
	- returns: a string key for the cache
	*/
	func cacheKey() -> String {
		let characterSet = CharacterSet(charactersIn:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_");
		let urlString = self.absoluteString
		var key = urlString.trimmingCharacters(in: characterSet.inverted)
		key = key.components(separatedBy: characterSet.inverted).joined(separator: "")
		return key
	}
	
}
