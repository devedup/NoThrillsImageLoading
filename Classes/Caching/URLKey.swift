//
//  URLKey.swift
//
//  Created by David Casserly on 18/11/2015.
//  Copyright © 2015 DevedUp Ltd. All rights reserved.
//

import UIKit

extension NSURL {

	/**
	Get a cache key for this url
	
	- returns: a string key for the cache
	*/
	func cacheKey() -> String {
		let characterSet = NSCharacterSet(charactersInString:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_");
		let urlString = self.absoluteString
		var key = urlString.stringByTrimmingCharactersInSet(characterSet.invertedSet)
		key = key.componentsSeparatedByCharactersInSet(characterSet.invertedSet).joinWithSeparator("")
		return key
	}
	
}
