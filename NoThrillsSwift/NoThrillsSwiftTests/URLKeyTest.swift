//
//  URLKeyTest.swift
//
//  Created by David Casserly on 18/11/2015.
//  Copyright © 2015 DevedUp Ltd. All rights reserved.
//

import XCTest
@testable import NoThrillsSwift

class URLKeyTest: XCTestCase {
	
    func testURLCacheKey() {
		let url = NSURL(string: "http://www.devedup.com/directory/toresrouce.jpg")
		
		let cacheKey = url?.cacheKey()
		
		let expected = "httpwwwdevedupcomdirectorytoresroucejpg"
		XCTAssertEqual(expected, cacheKey)
    }

    
}
