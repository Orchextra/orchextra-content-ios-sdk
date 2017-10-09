//
//  VideoPlayerPresenterPresenter.swift
//  OCM
//
//  Created by José Estela on 5/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

protocol VideoPlayerUI: class {
    func showLoadingIndicator()
    func dismissLoadingIndicator()
    func startVideo(_ video: Video)
}

class VideoPlayerPresenter {
    
    // MARK: - Public attributes
    
    weak var view: VideoPlayerUI?
    let wireframe: VideoPlayerWireframe
    let video: Video
    let videoInteractor: VideoInteractor
    
    // MARK: - Initializers
    
    init(view: VideoPlayerUI, wireframe: VideoPlayerWireframe, video: Video, videoInteractor: VideoInteractor) {
        self.view = view
        self.wireframe = wireframe
        self.video = video
        self.videoInteractor = videoInteractor
        self.videoInteractor.output = self
    }
    
    // MARK: - Input methods
    
    func viewDidLoad() {
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
        self.view?.startVideo(self.video)
        self.view?.dismissLoadingIndicator()
    }
}

extension VideoPlayerPresenter: VideoInteractorOutput {
    
    func videoInformationLoaded(_ video: Video?) {
        self.video.previewUrl = video?.previewUrl
        self.video.videoUrl = video?.videoUrl
        self.startVideo()
    }
}
