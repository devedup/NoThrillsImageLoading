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
		let imageResult = ImageCenter.imageForURL(imageURL) { (image, cancelled) -> Void in
			
			// Should have an image loaded now
			XCTAssertNotNil(image)
			
			// Try again, but it should now be in the cache
			let cachedImage = ImageCenter.imageForURL(imageURL, onCompletion: {_ in })
			XCTAssertNotNil(cachedImage)
			
			// Let the test end
			waitForImageLoad.fulfill()
		}
	
		// It shouldn't be in the cache, so it will return nil
		XCTAssertNil(imageResult.image)
		
		// If you want to cancel it you can use:
		//imageResult.operation?.cancel()
		
		// Wait for image to load from network
		waitForExpectationsWithTimeout(100.0, handler:nil)
    }

	
	func testImageCachingCancellingTheRequest() {
		let waitForCancellation = expectationWithDescription("Expecting an image load")
		
		let imageOne = NSURL(string:"https://media2.giphy.com/media/wzXlcBruMmzf2/200_s.gif")!
		let imageTwo = NSURL(string:"http://www.accrete.com/3dtextures/More3djayTextures/trees/got3d-tree23.png")!
		let imageThree = NSURL(string:"https://www.sapere.com/ckeditor_assets/pictures/35/content_oak_tree.png")!
		
		// The queue only runs 3, so four and five should be cancelled on time
		let one = ImageCenter.imageForURL(imageOne, onCompletion: {_ in })
		let two = ImageCenter.imageForURL(imageTwo, onCompletion: {_ in })
		let three = ImageCenter.imageForURL(imageThree) { (image, cancelled) -> Void in
			XCTAssertTrue(cancelled)
			XCTAssertNil(image)
			
			// Let the test end
			waitForCancellation.fulfill()
		}
		
		one.operation?.cancel()
		two.operation?.cancel()
		three.operation?.cancel()
		
		// Wait for image to load from network
		waitForExpectationsWithTimeout(100.0, handler:nil)
	}
	
}
