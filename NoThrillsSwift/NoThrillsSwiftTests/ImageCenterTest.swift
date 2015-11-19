//
//  ImageCenterTest.swift
//
//  Created by David Casserly on 18/11/2015.
//  Copyright © 2015 DevedUp Ltd. All rights reserved.
//

import XCTest
@testable import NoThrillsSwift

class ImageCenterTest: XCTestCase {
	
	override func tearDown() {
		let cache = DiskCache()
		cache.clearCache()
		
		super.tearDown()
	}

    func testImageCaching() {
		let waitForImageLoad = expectationWithDescription("Expecting an image load")
		
		let imageURL = NSURL(string:"https://media2.giphy.com/media/wzXlcBruMmzf2/200_s.gif")!
		let imageCenter = ImageCenter()
		let imageLoaded = imageCenter.imageForURL(imageURL) { (imageLoaded) -> Void in
			
			// Should have an image loaded now
			XCTAssertNotNil(imageLoaded)
			
			// Try again, but it should now be in the cache
			let cachedImage = imageCenter.imageForURL(imageURL, onNetworkLoad: {_ in })
			XCTAssertNotNil(cachedImage)
			
			// Let the test end
			waitForImageLoad.fulfill()
		}
	
		// It shouldn't be in the cache, so it will return nil
		XCTAssertNil(imageLoaded)
		
		// Wait for image to load from network
		waitForExpectationsWithTimeout(100.0, handler:nil)
    }

    
}
