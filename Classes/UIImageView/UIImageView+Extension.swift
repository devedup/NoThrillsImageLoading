//
//  UIImage+Extension.swift
//  NoThrillsImageLoading
//
//  Created by David Casserly on 29/10/2016.
//  Copyright © 2016 DevedUpLtd. All rights reserved.
//

import Foundation
import UIKit

public extension UIImageView {
    
    @discardableResult
    public func loadFrom(url: URL, httpHeaders: [String: String] = [:], completion: @escaping (Bool) -> Void) -> Operation {
        let operation = ImageCenter.imageForURL(url, httpHeaders: httpHeaders) { (response) -> Void in
            if let image = response.0, response.1 == url {
                self.image = image
                completion(true)
            } else {
                completion(false)
            }
        }
        return operation
    }
    
}
