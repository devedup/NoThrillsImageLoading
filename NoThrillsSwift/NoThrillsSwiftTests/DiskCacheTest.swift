//
//  DiskCacheTest.swift
//
//  Created by David Casserly on 18/11/2015.
//  Copyright © 2015 DevedUp Ltd. All rights reserved.
//

import XCTest
@testable import NoThrillsSwift

class DiskCacheTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreatingCacheDir() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let cache = DiskCache()
        _ = cache.cacheDir()
        _ = try! cache.pathForKey("dave")
        
    }
    
    func testCachingAndRetrieving() {
        let testData = NSData()
        let cache = DiskCache()
        cache.storeData(testData, forKey: "mykey")
        
        let data = cache.dataForKey("mykey")
        XCTAssertNotNil(data)
    }

    func testNoDataInCache() {
        let cache = DiskCache()
        
        let data = cache.dataForKey("notincache")
        XCTAssertNil(data)
    }
    
    func testClearingCache() {
        let testData = NSData()
        let cache = DiskCache()
        cache.storeData(testData, forKey: "beforeclear")
        
        let dataBefore = cache.dataForKey("beforeclear")
        XCTAssertNotNil(dataBefore)
        
        cache.clearCache()
        
        let dataAfter = cache.dataForKey("beforeclear")
        XCTAssertNil(dataAfter)
    }
    
}
