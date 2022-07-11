//
//  UIImage+Extension.swift
//  NoThrillsImageLoading
//
//  Created by David Casserly on 29/10/2016.
//  Copyright © 2016 DevedUpLtd. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    /// Convenience method to centre this view in its superview
    fileprivate func centreInSuperview() {
        guard let superview = self.superview else {
            preconditionFailure("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `centreInSuperview()` to fix this.")
        }
        translatesAutoresizingMaskIntoConstraints = false
        
        let x = centerXAnchor.constraint(equalTo: superview.centerXAnchor)
        let y = centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        
        NSLayoutConstraint.activate([x, y])
    }
    
}

public extension UIImageView {

    @discardableResult
    func loadFrom(url: URL, animationDuration: Double = 0.0, httpHeaders: [String: String]? = [:], priority: Priority = .normal, completion: ((UIImage?, Error?) -> Void)? = nil) -> Operation {
        let headers = httpHeaders ?? [:]
        let operation = ImageCenter.imageForURL(url, httpHeaders: headers) { (result) in
            switch result {
            case .success(let result):
                if result.url == url {
                    self.image = result.image
                    if animationDuration > 0.0 {
                        let transition = CATransition()
                        transition.duration = animationDuration
                        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                        transition.type = CATransitionType.fade;
                        self.layer.add(transition, forKey: nil)
                    }
                    completion?(result.image, nil)
                } else {
                    completion?(nil, nil)
                }
            case .failure(let error):
                completion?(nil, error)
            }
        }
        return operation
    }
    
    @discardableResult
    func loadFromConfirm(url: URL, animationDuration: Double = 0.0, httpHeaders: [String: String]? = [:], completion: ((UIImage?, URL?, Error?) -> Void)? = nil) -> Operation {
        let headers = httpHeaders ?? [:]
        let operation = ImageCenter.imageForURL(url, httpHeaders: headers) { (result) in
            switch result {
            case .success(let result):
                if result.url == url {
                    self.image = result.image
                    if animationDuration > 0.0 {
                        let transition = CATransition()
                        transition.duration = animationDuration
                        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                        transition.type = CATransitionType.fade;
                        self.layer.add(transition, forKey: nil)
                    }
                    completion?(result.image, url, nil)
                } else {
                    completion?(nil, url, nil)
                }
            case .failure(let error):
                completion?(nil, url, error)
            }
        }
        return operation
    }
}
