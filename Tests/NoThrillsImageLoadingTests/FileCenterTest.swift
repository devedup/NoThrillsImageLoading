//
//  FileCenterTest.swift
//  NoThrillsImageLoadingTests
//
//  Created by David Casserly on 19/03/2020.
//  Copyright © 2020 DevedUpLtd. All rights reserved.
//

import XCTest
@testable import NoThrillsImageLoading

class FileCenterTest: XCTestCase {

    func testURLReturned() {
        let waitForFileLoad = expectation(description:"Expecting a file load")
        
        let fileURL = URL(string:"http://127.0.0.1/files/sample.pdf")!
        FileCenter.filePathForURL(fileURL) { (result) in
            switch result {
            case .success(let data):
                print("File url path is \(data)")
            case .failure:
                XCTFail()
            }
            waitForFileLoad.fulfill()
        }

        // Wait for image to load from network
        waitForExpectations(timeout: 10.0, handler:nil)
        
    }

}
