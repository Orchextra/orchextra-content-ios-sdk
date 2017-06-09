//
//  BackgroundDownloadManager.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 09/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

enum BakgroundDownloadError: Error {
    
    case invalidUrl
    case retryLimitExceeded
    case unknown
    
    func description() -> String {
        switch self {
        case .invalidUrl:
            return "The provided URL is invalid, unable to start download"
        case .retryLimitExceeded:
            return "Unable to download after 3 attempts"
        case .unknown:
            return "Unable to download, unknown error"
        }
    }
}

protocol BackgroundDownloadDelegate: class {
    
    func downloadSucceeded(downloadPath: String, data: Data, location: URL)
    func downloadFailed(error: BakgroundDownloadError)
}

class BackgroundDownloadManager: NSObject {
    
    // MARK: Singleton
    public static let shared = BackgroundDownloadManager()
    
    // MARK: Public properties
    public weak var delegate: BackgroundDownloadDelegate?
    public var backgroundSessionCompletionHandler: (() -> Void)?
    
    // MARK: Private properties
    fileprivate var activeDownloads: [String: BackgroundDownload] = [:]
    fileprivate var backgroundDownloadSession: URLSession?
    fileprivate var backgroundSessionIdentifier: String = "ocm.bg.session.configuration"
    
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
    
    func configure(delegate: BackgroundDownloadDelegate, completionHandler: (() -> Void)?) {
        self.delegate = delegate
        self.backgroundSessionCompletionHandler = completionHandler
    }
    
    // MARK: - Download methods
    
    // TODO: Document !!!
    func startDownload(downloadPath: String) {
        
        guard let url = URL(string: downloadPath) else {
            self.delegate?.downloadFailed(error: .invalidUrl)
            return }
        
        if let downloadTask = self.backgroundDownloadSession?.downloadTask(with: url) {
            downloadTask.resume()
            self.activeDownloads[downloadPath] = BackgroundDownload(url: url, downloadTask: downloadTask)
        }
    }
    
    // TODO: Document
    func pauseDownload(downloadPath: String) {
        
        guard let download = self.activeDownloads[downloadPath], download.isDownloading else { return }
        
        download.downloadTask.cancel(byProducingResumeData: { (data: Data?) in
            download.resumeData = data
        })
        download.isDownloading = false
    }
    
    // TODO: Document
    func cancelDownload(downloadPath: String) {
        
        guard let download = self.activeDownloads[downloadPath] else { return }
        
        download.downloadTask.cancel()
        self.activeDownloads[downloadPath] = nil
    }
    
    // TODO: Document
    func resumeDownload(downloadPath: String) {
        
        guard let download = self.activeDownloads[downloadPath] else { return }
        
        if let downloadTask = self.backgroundDownloadSession?.downloadTask(with: download.url) {
            download.downloadTask = downloadTask
            download.downloadTask.resume()
            download.isDownloading = true
        }
    }
    
    // TODO: Document
    func retryDownload(downloadPath: String) {
        
        guard let download = self.activeDownloads[downloadPath], download.attempts < 3 else { return }
        
        if let downloadTask = self.backgroundDownloadSession?.downloadTask(with: download.url) {
            download.downloadTask = downloadTask
            download.downloadTask.resume()
            download.attempts += 1
        }
    }
}

extension BackgroundDownloadManager: URLSessionDelegate {
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if let completionHandler = self.backgroundSessionCompletionHandler {
            DispatchQueue.main.async(execute: {
                completionHandler()
            })
        }
    }
}

// MARK: - URLSessionDownloadDelegate

extension BackgroundDownloadManager: URLSessionDownloadDelegate {
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let data = try? Data(contentsOf: location),
            let downloadPath = downloadTask.originalRequest?.url?.absoluteString else {
                self.delegate?.downloadFailed(error: .unknown)
                return
        }
        self.activeDownloads[downloadPath] = nil
        self.delegate?.downloadSucceeded(downloadPath: downloadPath, data: data, location: location)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if let downloadPath = task.originalRequest?.url?.absoluteString {
            self.retryDownload(downloadPath: downloadPath)
        }
    }
}
