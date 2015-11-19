//
//  DiskCache.swift
//
//  Created by David Casserly on 18/11/2015.
//  Copyright © 2015 DevedUp Ltd. All rights reserved.
//

import Foundation

private enum DiskCacheError: ErrorType {
    case CacheNotAvailable
}

protocol DiskCache {
    
    /**
     Store data in the cache
     
     - parameter data: the data you want to store
     - parameter key:  the key for the data
     */
    func storeData(data: NSData, forKey key: String)
    
    /**
     Retrieve data from the cache
     
     - parameter key: the key for the data you want
     
     - returns: either the data or nil if it wasn't in the cache
     */
    func dataForKey(key: String) -> NSData?
 
    /**
     Remove everything in the cache
     */
    func clearCache()
}

class DefaultDiskCache: DiskCache {


    func storeData(data: NSData, forKey key: String) {
        do {
            let path = try pathForKey(key)
            data.writeToFile(path, atomically: true)
        } catch {
            print("Could not write data to cache")
        }
    }
    

    func dataForKey(key: String) -> NSData? {
        do {
            let path = try pathForKey(key)
            return NSData(contentsOfFile: path)
        } catch {
            print("Could not retrieve from cache")
            return nil
        }
    }
    
    func clearCache() {
        do {
            let path = try pathForKey("")
            let fm = NSFileManager()
            try fm.removeItemAtPath(path)
        } catch {
            print("Could not clear the cache")
        }
    }


    // MARK: Private
    
    /**
    Get the path for the key provided from the cache
    
    - parameter key: the key of the item you want
    
    - throws: DiskCacheError.CacheNotAvailable if something went wrong
    
    - returns: the path for the item you want
    */
    internal func pathForKey(key: String) throws -> String {
        guard let cache = cacheDir() else {
            throw DiskCacheError.CacheNotAvailable
        }
        
        let path = "\(cache)/\(key)"
        return path
    }
    
    /**
     Get the caches dir which is the default device Caches dir with 'diskcache' directory appended
     
     - returns: the cache dir
     */
    internal func cacheDir() -> String? {
        let dirs = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        let cachesDir = "\(dirs[0])/diskcache"
        let fm = NSFileManager()
        var isDir: ObjCBool = true
        if !fm.fileExistsAtPath(cachesDir, isDirectory: &isDir) {
            do {
                try fm.createDirectoryAtPath(cachesDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Couldn't create cachesDir in caches directory")
                return nil
            }
        }
        return cachesDir
    }
    
}
