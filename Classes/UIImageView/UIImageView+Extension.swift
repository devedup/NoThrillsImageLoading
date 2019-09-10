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
    func loadFrom(url: URL, httpHeaders: [String: String] = [:], completion: @escaping (UIImage?) -> Void) -> Operation {
        let operation = ImageCenter.imageForURL(url, httpHeaders: httpHeaders) { (imageP, urlP) -> Void in
            if let image = imageP, url == urlP {
                self.image = image
                completion(image)
            } else {
                completion(nil)
            }
        }
        return operation
    }
    
}
