//
//  VideoPlayerVCVC.swift
//  OCM
//
//  Created by José Estela on 5/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary
import AVFoundation
import AVKit

class VideoPlayerVC: OCMViewController {
    
    // MARK: - Attributtes
    
    var presenter: VideoPlayerPresenter?
    var activityIndicator = ImageActivityIndicator(frame: CGRect(origin: .zero, size: CGSize(width: 25, height: 25)), image: UIImage.OCM.loadingIcon ?? UIImage())
    var player: VideoPlayer?
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.visibleWhenStopped = false
        self.view.backgroundColor = .black
        self.player = VideoPlayer.fullscreenPlayer(in: self)
        self.player?.delegate = self
        self.view.addSubview(self.activityIndicator, settingAutoLayoutOptions: [
            .centerY(to: self.view),
            .centerX(to: self.view)
        ])
        self.presenter?.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter?.viewDidAppear()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}

// MARK: - VideoPlayerDelegate

extension VideoPlayerVC: VideoPlayerDelegate {
    
    func videoPlayerDidExitFromFullScreen(_ videoPlayer: VideoPlayer) {
        // Todo nothing
    }
    
    func videoPlayerDidPause(_ videoPlayer: VideoPlayer) {
        self.presenter?.videoDidPause()
    }
    
    func videoPlayerDidStart(_ videoPlayer: VideoPlayer) {
        self.presenter?.videoDidStart()
    }
    
    func videoPlayerDidStop(_ videoPlayer: VideoPlayer) {
       self.presenter?.videoDidStop()
    }
    
    func videoPlayerDidFinish(_ videoPlayer: VideoPlayer) {
        self.presenter?.dismiss()
    }
}

// MARK: - VideoPlayerUI

extension VideoPlayerVC: VideoPlayerUI {
    
    func showLoadingIndicator() {
        self.activityIndicator.startAnimating()
    }
    
    func dismissLoadingIndicator() {
        self.activityIndicator.stopAnimating()
    }
    
    func showVideoPlayer() {
        self.player?.show()
        self.view.bringSubviewToFront(self.activityIndicator)
    }
    
    func startVideo(_ url: URL) {
        self.player?.url = url
        self.player?.play()
    }
}
