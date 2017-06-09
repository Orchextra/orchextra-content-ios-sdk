//
//  BackgroundDownload.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 09/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

// TODO: Document !!!
class BackgroundDownload {
    
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
