//
//  DownloadOperation.swift
//  NoThrillsImageLoading
//
//  Created by David Casserly on 19/03/2020.
//  Copyright © 2020 DevedUpLtd. All rights reserved.
//

import Foundation

enum DownloadError: Error {
    case cancelled
    case unknown
}

public class DownloadOperation: Operation {
        
    static let urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default)
    
    private let onLoad: (Result<Data,Error>) -> Void
    private let url: URL
    private let httpHeaders: [String: String]
    private var downloadTask: URLSessionDataTask?
    private let priority: Priority
    
    init(url: URL, httpHeaders: [String: String], priority: Priority = .normal, onLoad: @escaping (Result<Data,Error>) -> Void) {
        self.onLoad = onLoad
        self.url = url
        self.httpHeaders = httpHeaders
        self.priority = priority
    }
    
    public override func cancel() {
        super.cancel()
        downloadTask?.cancel()
        noThrillDebug("Cancelled \(self.url.absoluteString)")
    }
    
    public override func main() {
        // Wrap the completion block to ensure dispatched to main queue and not have dispatch_async blocks
        // literring this method
        let downloadCompletion: (Result<Data,Error>) -> Void = { (result) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                switch result {
                case .success(let data):
                    self.onLoad(.success(data))
                case .failure(let error):
                    self.onLoad(.failure(error))
                }
            })
        }
        
        guard !self.isCancelled else {
            downloadCompletion(.failure(DownloadError.cancelled))
            return
        }

        noThrillDebug("Loading image from network from \(self.url.absoluteString)")
                
        let session = DownloadOperation.urlSession
        var urlRequest = URLRequest(url: self.url)
        for (key, value) in httpHeaders {
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        
        downloadTask = session.dataTask(with: urlRequest) { (data, response, error) in
            guard !self.isCancelled else {
                downloadCompletion(.failure(DownloadError.cancelled))
                self.downloadTask?.cancel()
                return
            }
            
            guard let data = data else {
                if let error = error {
                    downloadCompletion(.failure(error))
                } else {
                    downloadCompletion(.failure(DownloadError.unknown))
                }
                return
            }
            
            noThrillDebug("Loaded image from network \(self.url.absoluteString)")
            downloadCompletion(.success(data))
        }
        downloadTask?.priority = self.priority.queuePriority
        downloadTask?.resume()
        
        if self.isCancelled {
            downloadCompletion(.failure(DownloadError.cancelled))
            downloadTask?.cancel()
            return
        }
    }
    
}
