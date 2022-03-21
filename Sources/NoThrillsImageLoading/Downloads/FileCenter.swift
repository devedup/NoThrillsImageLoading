//
//  ImageCenter.swift
//
//  Created by David Casserly on 18/11/2015.
//  Copyright © 2015 DevedUp Ltd. All rights reserved.
//

import UIKit

enum FileCenterError: Error {
    case couldNotCache
}

@objc
public class FileCenterObjC: NSObject {
    
    @objc
    @discardableResult
    public class func filePathForURL(_ url: URL, httpHeaders: [String: String] = [:], onFileLoad: @escaping (URL?, Error?) -> Void) -> DownloadOperation {
        FileCenter.filePathForURL(url, httpHeaders: httpHeaders) { (result) in
            switch result {
            case .success(let data):
                onFileLoad(data, nil)
            case .failure(let error):
                onFileLoad(nil, error)
            }
        }
    }
    
}

public class FileCenter {
    
    static var diskCache: Cache = DefaultDiskCache()
    
    private static var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "File download queue"
        queue.maxConcurrentOperationCount = 5
        return queue
    }()
    
    private static var cacheCheckQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "File cache check queue"
        queue.maxConcurrentOperationCount = 20
        return queue
    }()
    
    /**
    If image is in the cache return it immediately, otherwise it will come back in the completion block
    
    - parameter url:        url of the image
    - parameter completion: the completion block with the imag
    
    - returns: an operation which can be cancelled, or contains image from cache
    */
    @discardableResult
    public class func filePathForURL(_ url: URL, httpHeaders: [String: String] = [:], onFileLoad: @escaping (Result<(URL), Error>) -> Void) -> DownloadOperation {
        
        let cacheKey = url.cacheKey()
        
        let fileOperation = DownloadOperation(url: url, httpHeaders: httpHeaders) { (result) in
            switch result {
            case .success(let data):
                if let url = self.diskCache.storeData(data, forKey: cacheKey) {
                    onFileLoad(.success(url))
                } else {
                    onFileLoad(.failure(FileCenterError.couldNotCache))
                }
            case .failure(let error):
                onFileLoad(.failure(error))
            }
        }
            
        let cacheCheck = BlockOperation { () -> Void in
            if let cachedFileURL = FileCenter.urlFromCache(cacheKey: cacheKey) {
                DispatchQueue.main.async(execute: { () -> Void in
                    onFileLoad(.success(cachedFileURL))
                })
            } else {
                downloadQueue.addOperation(fileOperation)
            }
        }
        cacheCheckQueue.addOperation(cacheCheck)
        
        return fileOperation
    }
    
    private class func urlFromCache(cacheKey key: String) -> URL? {
        if let cacheURL = FileCenter.diskCache.cachedFileURL(key) {
            noThrillDebug("Loaded image from disk cache \(key)")
            return cacheURL
        } else {
            return nil
        }
    }
    
    /**
     Cancel all pending image load operations
     */
    class func cancelAllImageOperations() {
        downloadQueue.cancelAllOperations()
    }
        
}
