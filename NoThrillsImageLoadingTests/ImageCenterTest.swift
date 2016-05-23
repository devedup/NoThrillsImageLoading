//
//  ImageCenterTest.swift
//
//  Created by David Casserly on 18/11/2015.
//  Copyright © 2015 DevedUp Ltd. All rights reserved.
//

import XCTest
@testable import NoThrillsImageLoading

class ImageCenterTest: XCTestCase {
	
	override func tearDown() {
		let cache = DefaultDiskCache()
		cache.clearCache()
		
		super.tearDown()
	}

    func testImageCaching() {
		let waitForImageLoad = expectationWithDescription("Expecting an image load")
		
		let imageURL = NSURL(string:"http://www.accrete.com/3dtextures/More3djayTextures/trees/got3d-tree23.png")!
		let imageOp = ImageCenter.imageForURL(imageURL) { (image, url) -> Void in
			
			// Should have an image loaded now
			XCTAssertNotNil(image)
			
			// Try again, but it should now be in the cache
			let _ = ImageCenter.imageForURL(imageURL, onImageLoad: { (image, url) -> Void in
                XCTAssertNotNil(image)
            })
			
			// Let the test end
			waitForImageLoad.fulfill()
		}
	
        // Image not in cache, so an operation should have started
        XCTAssertNotNil(imageOp)
		
		// If you want to cancel it you can use:
		//imageOp?.cancel()
		
		// Wait for image to load from network
		waitForExpectationsWithTimeout(10.0, handler:nil)
    }

	
	func testImageCachingCancellingTheRequest() {
		let imageOne = NSURL(string:"https://media2.giphy.com/media/wzXlcBruMmzf2/200_s.gif")!
		let imageTwo = NSURL(string:"http://www.accrete.com/3dtextures/More3djayTextures/trees/got3d-tree23.png")!
		let imageThree = NSURL(string:"https://www.sapere.com/ckeditor_assets/pictures/35/content_oak_tree.png")!
		
		// The queue only runs 3, so four and five should be cancelled on time
		let one = ImageCenter.imageForURL(imageOne, onImageLoad: {_ in })
		let two = ImageCenter.imageForURL(imageTwo, onImageLoad: {_ in })
		let three = ImageCenter.imageForURL(imageThree) { (image) -> Void in
            XCTFail()
		}
		
		one.cancel()
		two.cancel()
		three.cancel()
		
	}
	
	func testURLReturned() {
		let waitForImageLoad = expectationWithDescription("Expecting an image load")
		
		let imageURL = NSURL(string:"http://www.accrete.com/3dtextures/More3djayTextures/trees/got3d-tree23.png")!
		ImageCenter.imageForURL(imageURL) { (image, url) -> Void in
			XCTAssertEqual(imageURL, url)
			// Let the test end
			waitForImageLoad.fulfill()
		}

		// Wait for image to load from network
		waitForExpectationsWithTimeout(10.0, handler:nil)
		
	}
	
	
}
