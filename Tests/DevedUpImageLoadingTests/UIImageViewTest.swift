//
//  UIImageViewTest.swift
//  NoThrillsImageLoading
//
//  Created by David Casserly on 29/10/2016.
//  Copyright © 2016 DevedUpLtd. All rights reserved.
//

import XCTest
import UIKit
@testable import DevedUpImageLoading

class ImageViewCenterTest: XCTestCase {
    
    override func tearDown() {
        let cache = DefaultDiskCache()
        cache.clearCache()
        super.tearDown()
    }
    
    func testImageViewLoad() {
        let waitForImageLoad = expectation(description: "Expecting an image load")
        
        let imageURL = URL(string:"https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png")!
        let imageView = UIImageView()
        let imageOp = imageView.loadFrom(url: imageURL) { (success, error) in
            XCTAssertTrue((success != nil))
            if let image = imageView.image {
                XCTAssertNotNil(image)
            } else {
                XCTFail()
            }
            waitForImageLoad.fulfill()
        }
        
        // Image not in cache, so an operation should have started
        XCTAssertNotNil(imageOp)
        // If you want to cancel it you can use:
        //imageOp?.cancel()
        
        // Wait for image to load from network
        waitForExpectations(timeout:10.0, handler:nil)
    }
    
}
