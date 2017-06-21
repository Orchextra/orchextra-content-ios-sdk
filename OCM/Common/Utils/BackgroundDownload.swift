//
//  BackgroundDownload.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 09/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

/// Represents a background download
class BackgroundDownload {
    
    /// Request's URL
    var url: URL
    /// Download state, `true` if it's active, `false` if it's paused
    var isDownloading: Bool
    /// Download task
    var downloadTask: URLSessionDownloadTask
    /// Resume data for a paused download
    var resumeData: Data?
    /// Number of attemps to perform the download
    var attempts: Int
    /// Completion handler
    var completionHandler: BackgroundDownloadCompletion
    
    // MARK: Initializer
    
    init(url: URL, downloadTask: URLSessionDownloadTask, completion: @escaping BackgroundDownloadCompletion) {
        self.url = url
        self.isDownloading = true
        self.downloadTask = downloadTask
        self.attempts = 1
        self.completionHandler = completion
    }
}
