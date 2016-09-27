//
//  DiskCache.swift
//
//  Created by David Casserly on 18/11/2015.
//  Copyright © 2015 DevedUp Ltd. All rights reserved.
//

import Foundation

private enum DiskCacheError: Error {
    case cacheNotAvailable
}

class DefaultDiskCache: Cache {


    func storeData(_ data: Data, forKey key: String) {
        do {
            let path = try pathForKey(key)
            try? data.write(to: URL(fileURLWithPath: path), options: [.atomic])
        } catch {
            print("Could not write data to cache")
        }
    }
    

    func dataForKey(_ key: String) -> Data? {
        do {
            let path = try pathForKey(key)
            return (try? Data(contentsOf: URL(fileURLWithPath: path)))
        } catch {
            print("Could not retrieve from cache")
            return nil
        }
    }
    
    func clearCache() {
        do {
            let path = try pathForKey("")
            let fm = FileManager()
            try fm.removeItem(atPath: path)
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
    internal func pathForKey(_ key: String) throws -> String {
        guard let cache = cacheDir() else {
            throw DiskCacheError.cacheNotAvailable
        }
        
        let path = "\(cache)/\(key)"
        return path
    }
    
    /**
     Get the caches dir which is the default device Caches dir with 'diskcache' directory appended
     
     - returns: the cache dir
     */
    internal func cacheDir() -> String? {
        let dirs = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let cachesDir = "\(dirs[0])/diskcache"
        let fm = FileManager()
        var isDir: ObjCBool = true
        if !fm.fileExists(atPath: cachesDir, isDirectory: &isDir) {
            do {
                try fm.createDirectory(atPath: cachesDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Couldn't create cachesDir in caches directory")
                return nil
            }
        }
        return cachesDir
    }
    
}
