//
//  VideoPlayerPresenter.swift
//  OCM
//
//  Created by José Estela on 5/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

protocol VideoPlayerUI: class {
    func showLoadingIndicator()
    func dismissLoadingIndicator()
    func showVideoPlayer()
    func startVideo(_ url: URL)
}

class VideoPlayerPresenter {
    
    // MARK: - Public attributes
    
    weak var view: VideoPlayerUI?
    let wireframe: VideoPlayerWireframeInput
    let video: Video
    let videoInteractor: VideoInteractor
    
    // MARK: - Initializers
    
    init(view: VideoPlayerUI, wireframe: VideoPlayerWireframeInput, video: Video, videoInteractor: VideoInteractor) {
        self.view = view
        self.wireframe = wireframe
        self.video = video
        self.videoInteractor = videoInteractor
        self.videoInteractor.output = self
    }
    
    // MARK: - Input methods
    
    func viewDidLoad() {
        self.view?.showVideoPlayer()
        self.view?.showLoadingIndicator()
    }
    
    func viewDidAppear() {
        if self.video.videoUrl != nil {
            self.startVideo()
        } else {
            self.videoInteractor.loadVideoInformation(for: self.video)
        }
    }
    
    func dismiss() {
        self.wireframe.dismiss()
    }
    
    // MARK: - Private methods
        
    func startVideo() {
        if let videoURL = video.videoUrl, let url = URL(string: videoURL) {
            self.view?.startVideo(url)
            self.view?.dismissLoadingIndicator()
        } else {
            self.wireframe.dismiss()
        }
    }
    
    func videoDidStart() {
        guard let videoEventDelegate = OCM.shared.videoEventDelegate, let videoURL = video.videoUrl else { return }
        videoEventDelegate.videoDidStart(identifier: videoURL)
    }
    
    func videoDidStop() {
        guard let videoEventDelegate = OCM.shared.videoEventDelegate, let videoURL = video.videoUrl else { return }
        videoEventDelegate.videoDidStop(identifier: videoURL)
    }
    
    func videoDidPause() {
        guard let videoEventDelegate = OCM.shared.videoEventDelegate, let videoURL = video.videoUrl else { return }
        videoEventDelegate.videoDidPause(identifier: videoURL)
    }
}

extension VideoPlayerPresenter: VideoInteractorOutput {
    
    func videoInformationLoaded(_ video: Video?) {
        self.video.previewUrl = video?.previewUrl
        self.video.videoUrl = video?.videoUrl
        self.startVideo()
    }
}
