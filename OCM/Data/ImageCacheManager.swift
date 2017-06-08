//
//  ImageCacheManager.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 07/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

public enum ImageCacheError: Error {
    
    case invalidURL
    case retryLimitExceeded
    case cachingFailed
    case unknown
    
    func description() -> String {
        switch self {
        case .invalidURL:
            return "The provided URL is invalid, unable to download expected image"
        case .retryLimitExceeded:
            return "Unable to download expected image after 3 attempts"
        case .cachingFailed:
            return "Unable to cache on disk the expected image"
        case .unknown:
            return "Unable to cache image, unknown error"
        }
    }
}

class ImageDownload {
    
    var url: URL
    var isDownloading: Bool
    var downloadTask: URLSessionDownloadTask
    var resumeData: Data?
    var attempts: Int
    
    init(url: URL, downloadTask: URLSessionDownloadTask) {
        self.url = url
        self.isDownloading = true
        self.downloadTask = downloadTask
        self.attempts = 1
    }
}

class CachedImage {
    
    let imagePath: String
    let location: URL
    //var associatedContent: [Any] // For garbage collection !!! ???
    
    init(imagePath: String, location: URL) {
        self.imagePath = imagePath
        self.location = location
        //self.associatedContent = [associatedContent]
    }
}

public protocol ImageCacheDelegate: class {
    
    func loadedImage(_ image: UIImage)
    func failedToLoadImage(error: ImageCacheError)
}

/// TODO: Document properly !!! Manager for caching images
public class ImageCacheManager: NSObject {
    
    // MARK: Singleton
    public static let shared = ImageCacheManager()

    // MARK: Public properties
    public weak var delegate: ImageCacheDelegate? //!!!
    
    // MARK: Private properties
    fileprivate var cachedImages: [CachedImage] = []
    fileprivate var activeDownloads: [String: ImageDownload] = [:]
    fileprivate var backgroundDownloadSession: URLSession?
    fileprivate var backgroundSessionIdentifier: String = "ocm.bg.session.configuration"
    fileprivate var backgroundSessionCompletionHandler: (() -> Void)? //!!! ??? 666
    
    // MARK: - Initializers
    
    override init() {
        super.init()
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: self.backgroundSessionIdentifier)
        self.backgroundDownloadSession = URLSession(
            configuration: backgroundConfiguration,
            delegate: self,
            delegateQueue: .none) // !!! Maybe use the queue?
    }
    
    // MARK: - Public methods
    
    public func configure(delegate: ImageCacheDelegate) {
        self.delegate = delegate
    }
    
    public func handleEventsForBackgroundURLSession(identifier: String, completionHandler: @escaping () -> Void) {
        if identifier == self.backgroundSessionIdentifier {
            self.backgroundSessionCompletionHandler = completionHandler
        }
    }
   
    // MARK: - Private helpers
    
    func clean() {
    
        // TODO: !!!
        // Perform garbage collection
    }

    // MARK: - Download methods
    
    // TODO: Document !!!
    func startDownload(imagePath: String) {
        
        guard let imageURL = URL(string: imagePath) else { return } //!!! with error?
        
        if let downloadTask = self.backgroundDownloadSession?.downloadTask(with: imageURL) {
            downloadTask.resume()
            self.activeDownloads[imagePath] = ImageDownload(url: imageURL, downloadTask: downloadTask)
        }
    }
    
    // TODO: Document
    func pauseDownload(imagePath: String) {
        
        guard let imageDownload = self.activeDownloads[imagePath], imageDownload.isDownloading else { return }
        
        imageDownload.downloadTask.cancel(byProducingResumeData: { (data: Data?) in
            imageDownload.resumeData = data
        })
        imageDownload.isDownloading = false
    }
    
    // TODO: Document
    func cancelDownload(imagePath: String) {
        
        guard let imageDownload = self.activeDownloads[imagePath] else { return }
        
        imageDownload.downloadTask.cancel()
        self.activeDownloads[imagePath] = nil
    }
    
    // TODO: Document
    func resumeDownload(imagePath: String) {
        
        guard let imageDownload = self.activeDownloads[imagePath] else { return }
        
        if let downloadTask = self.backgroundDownloadSession?.downloadTask(with: imageDownload.url) {
            imageDownload.downloadTask = downloadTask
            imageDownload.downloadTask.resume()
            imageDownload.isDownloading = true
        }
    }
    
    // TODO: Document
    func retryDownload(imagePath: String) {
        
        guard let imageDownload = self.activeDownloads[imagePath], imageDownload.attempts < 3 else { return }
        
        if let downloadTask = self.backgroundDownloadSession?.downloadTask(with: imageDownload.url) {
            imageDownload.downloadTask = downloadTask
            imageDownload.downloadTask.resume()
            imageDownload.attempts += 1
        }
    }
    
    // MARK: Download helper methods
    
    func documentsPath() -> String? {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
    }
    
    func localFilePathForImage(imagePath: String) -> URL? {
        if let documentsPath = self.documentsPath() {
            let url = URL(fileURLWithPath: documentsPath + imagePath)
            return url
        }
        return nil
    }

}

extension ImageCacheManager: URLSessionDelegate {
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if let completionHandler = self.backgroundSessionCompletionHandler {
            self.backgroundSessionCompletionHandler = nil
            DispatchQueue.main.async(execute: {
                completionHandler()
            })
        }
    }
}

// MARK: - URLSessionDownloadDelegate

extension ImageCacheManager: URLSessionDownloadDelegate {

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let data = try? Data(contentsOf: location),
        let image = UIImage(data: data),
        let imagePath = downloadTask.originalRequest?.url?.absoluteString,
        let destinationURL = localFilePathForImage(imagePath: imagePath) else {
            self.delegate?.failedToLoadImage(error: .unknown)
            return
        }
        
        try? FileManager.default.removeItem(at: destinationURL)
        do {
            try FileManager.default.moveItem(at: location, to: destinationURL)
            self.activeDownloads[imagePath] = nil
            let cachedImage = CachedImage(imagePath: imagePath, location: destinationURL)
            self.cachedImages.append(cachedImage)
            self.delegate?.loadedImage(image)
        } catch {
            self.delegate?.failedToLoadImage(error: .cachingFailed)
        }
        
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if let imagePath = task.originalRequest?.url?.absoluteString {
            self.retryDownload(imagePath: imagePath)
        }
    }
}
