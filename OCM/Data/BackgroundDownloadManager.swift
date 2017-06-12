//
//  BackgroundDownloadManager.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 09/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

/// Error for a background download
enum BackgroundDownloadError: Error {
    
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

/// Background download on completion receives the downloaded data or an error
typealias BackgroundDownloadCompletion = (URL?, BackgroundDownloadError?) -> Void

/**
 Handles background downloads, responsible for:
 - Firing background downloads.
 - Handle events for downloads, i.e.: success and error cases.
 - Pause all active downloads.
 - Resume all paused downloads.
 - Cancel all downloads.
 - Retry failed downloads (maximum of 3 attempts).
*/
class BackgroundDownloadManager: NSObject {
    
    // MARK: Singleton
    
    /// Singleton
    public static let shared = BackgroundDownloadManager()
    
    // MARK: Public properties
    
    /// Completion handler for finished background tasks triggered by the `UIApplication` delegate
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
    
    /**
     Configures the `BackgroundDownloadManager`. This method *must* be called after instance initialization.
     
     - parameter completionHandler: Completion handler for finished background tasks triggered by the `UIApplication` delegate.
     */
    func configure(backgroundSessionCompletionHandler: (() -> Void)?) {
        self.backgroundSessionCompletionHandler = backgroundSessionCompletionHandler
    }
    
    // MARK: - Download methods
    
    /**
     Fires a download background task.
     
     - parameter downloadPath: `String` representation of the download's URL.
     - parameter completion: Completion handler for success and error events.
     */
    func startDownload(downloadPath: String, completion: @escaping BackgroundDownloadCompletion) {
        
        guard let url = URL(string: downloadPath) else {
            completion(.none, .invalidUrl)
            return
        }
        
        if let downloadTask = self.backgroundDownloadSession?.downloadTask(with: url) {
            downloadTask.resume()
            self.activeDownloads[downloadPath] = BackgroundDownload(url: url, downloadTask: downloadTask, completion: completion)
        }
    }
    
    /**
     Pauses an active download task.
     
     - parameter downloadPath: `String` representation of the download's URL.
     */
    func pauseDownload(downloadPath: String) {
        
        guard let download = self.activeDownloads[downloadPath], download.isDownloading else { return }
        
        download.downloadTask.cancel(byProducingResumeData: { (data: Data?) in
            download.resumeData = data
        })
        download.isDownloading = false
    }
    
    /**
    Cancels a download task, whether it's active or not.
    
    - parameter downloadPath: `String` representation of the download's URL.
    */
    func cancelDownload(downloadPath: String) {
        
        guard let download = self.activeDownloads[downloadPath] else { return }
        
        download.downloadTask.cancel()
        self.activeDownloads[downloadPath] = nil
    }
    
    /**
     Resumes a paused download task.
     
     - parameter downloadPath: `String` representation of the download's URL.
     */
    func resumeDownload(downloadPath: String) {
        
        guard let download = self.activeDownloads[downloadPath], !download.isDownloading else { return }
        
        if let downloadTask = self.backgroundDownloadSession?.downloadTask(with: download.url) {
            download.downloadTask = downloadTask
            download.downloadTask.resume()
            download.isDownloading = true
        }
    }
    
    /**
     Attempts to execute a download task that failed previously. Maximum number of attempts: 3
     
     - parameter downloadPath: `String` representation of the download's URL.
     */
    func retryDownload(downloadPath: String) {
        
        guard let download = self.activeDownloads[downloadPath] else { return }
        
        guard download.attempts < 3 else {
            download.completionHandler(.none, .retryLimitExceeded)
            return
        }
        
        if let downloadTask = self.backgroundDownloadSession?.downloadTask(with: download.url) {
            download.downloadTask = downloadTask
            download.downloadTask.resume()
            download.attempts += 1
        }
    }
    
    /**
     Resumes all acitve download tasks.
     */
    func pauseDownloads() {
        
        for download in self.activeDownloads {
            self.pauseDownload(downloadPath: download.key)
        }
    }
    
    /**
     Resumes all paused download tasks.
     */
    func resumeDownloads() {
        
        for download in self.activeDownloads {
            self.resumeDownload(downloadPath: download.key)
        }
    }
    
    /**
     Cancels all handled download task, whether they're active or not.
     */
    func cancelDownloads() {
        
        for download in self.activeDownloads {
            self.cancelDownload(downloadPath: download.key)
        }
    }
}

// MARK: - URLSessionDelegate

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
        
        guard let downloadPath = downloadTask.originalRequest?.url?.absoluteString,
        let download = self.activeDownloads[downloadPath] else {
            return
        }
        
        // Move temporary file to a permanent location on the documents directory
        guard let destinationURL = self.permanentLocationForDownload(downloadPath: downloadPath) else {
            download.completionHandler(.none, .unknown)
            return
        }
        try? FileManager.default.removeItem(at: destinationURL)
        do {
            try FileManager.default.moveItem(at: location, to: destinationURL)
            download.completionHandler(location, .none)
        } catch {
            download.completionHandler(.none, .unknown)
        }
    
        // Remove from active downloads
        self.activeDownloads[downloadPath] = nil
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if let downloadPath = task.originalRequest?.url?.absoluteString {
            self.retryDownload(downloadPath: downloadPath)
        }
    }
    
    // MARK: Helpers

    private func permanentLocationForDownload(downloadPath: String) -> URL? {
        
        guard let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return nil }
        return URL(fileURLWithPath: documentsPath + downloadPath)
    }
    
}
