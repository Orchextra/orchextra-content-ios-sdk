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

/// Background download on completion receives the name for the file with downloaded data or an error
typealias BackgroundDownloadCompletion = (String?, BackgroundDownloadError?) -> Void

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
            delegateQueue: .none)
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
        
        if let download = self.activeDownloads[downloadPath], !download.isDownloading {
            // If it's a download that was paused, resume
            self.resumeDownload(downloadPath: downloadPath)
        } else {
            if let downloadTask = self.backgroundDownloadSession?.downloadTask(with: url) {
                downloadTask.resume()
                self.activeDownloads[downloadPath] = BackgroundDownload(url: url, downloadTask: downloadTask, completion: completion)
            }
        }
    }
    
    /**
     Pauses an active download task.
     
     - parameter downloadPath: `String` representation of the download's URL.
     */
    func pauseDownload(downloadPath: String) {
        
        guard let download = self.activeDownloads[downloadPath], download.isDownloading else { logWarn("activeDownloads is nil"); return }
        
        download.downloadTask.cancel(byProducingResumeData: { (data: Data?) in
            download.resumeData = data
        })
        download.isDownloading = false
    }
    
    /**
     Resumes a paused download task.
     
     - parameter downloadPath: `String` representation of the download's URL.
     */
    func resumeDownload(downloadPath: String) {
        
        guard let download = self.activeDownloads[downloadPath], !download.isDownloading else { logWarn("activeDownloads is nil"); return }
        
        if let downloadTask = self.backgroundDownloadSession?.downloadTask(with: download.url) {
            download.downloadTask = downloadTask
            download.downloadTask.resume()
            download.isDownloading = true
        }
    }
    
    /**
    Cancels a download task, whether it's active or not.
    
    - parameter downloadPath: `String` representation of the download's URL.
    */
    func cancelDownload(downloadPath: String) {
        
        guard let download = self.activeDownloads[downloadPath] else { logWarn("activeDownloads is nil"); return }
        
        download.downloadTask.cancel()
        self.activeDownloads[downloadPath] = nil
    }
    
    /**
     Attempts to execute a download task that failed previously. Maximum number of attempts: 3
     
     - parameter downloadPath: `String` representation of the download's URL.
     */
    func retryDownload(downloadPath: String) {
        
        logInfo("BackgroundDownloadManager - Background download FAILED, will try again. Path for download: \(downloadPath).")
        guard let download = self.activeDownloads[downloadPath] else { logWarn("activeDownloads is nil"); return }
        
        guard download.attempts < 3 else {
            
            logWarn("BackgroundDownloadManager - Background download FAILED, retry limit exceeded. Path for download: \(downloadPath).")
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
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
        if let completionHandler = self.backgroundSessionCompletionHandler {
            DispatchQueue.main.async(execute: {
                completionHandler()
            })
        }
    }
}

// MARK: - URLSessionDownloadDelegate

extension BackgroundDownloadManager: URLSessionDownloadDelegate {
    

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let downloadPath = downloadTask.originalRequest?.url?.absoluteString,
        let download = self.activeDownloads[downloadPath] else {
            return
        }
        
        // Move temporary file to a permanent location on the documents directory
        let filename = "download-\(downloadPath.hashValue)"
        guard let destinationURL = self.permanentLocationForDownload(filename: filename) else {
            logWarn("BackgroundDownloadManager - Saving data from background download FAILED. Path for download: \(downloadPath).")
            download.completionHandler(.none, .unknown)
            return
        }
        try? FileManager.default.removeItem(at: destinationURL)
        do {
            try FileManager.default.moveItem(at: location, to: destinationURL)
            logInfo("BackgroundDownloadManager - Background download SUCCEEDED. Path for download: \(downloadPath).")
            download.completionHandler(filename, .none)
        } catch {
            logWarn("BackgroundDownloadManager - Saving data from background download FAILED. Path for download: \(downloadPath).")
            download.completionHandler(.none, .unknown)
        }
    
        // Remove from active downloads
        self.activeDownloads[downloadPath] = nil
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if let downloadPath = task.originalRequest?.url?.absoluteString {
            
            if error != nil {
                self.retryDownload(downloadPath: downloadPath)
            }
        }
    }
    
    // MARK: Helpers

    private func permanentLocationForDownload(filename: String) -> URL? {
        
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentsUrl.appendingPathComponent(filename)
    }
    
}
