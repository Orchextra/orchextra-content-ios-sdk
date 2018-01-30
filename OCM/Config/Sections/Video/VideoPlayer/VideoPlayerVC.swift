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

class VideoPlayerVC: OrchextraViewController {
    
    // MARK: - Attributtes
    
    var presenter: VideoPlayerPresenter?
    var activityIndicator: UIActivityIndicatorView?
    var player: VideoPlayerView?
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator = UIActivityIndicatorView()
        self.activityIndicator?.hidesWhenStopped = true
        self.player = VideoPlayerView.fullScreenPlayer(in: self)
        self.player?.delegate = self
        if let activityIndicator = self.activityIndicator {
            self.view.addSubview(activityIndicator, settingAutoLayoutOptions: [
                .centerY(to: self.view),
                .centerX(to: self.view)
            ])
        }
        self.presenter?.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // self.player?.unregisterFromNotifications()
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

extension VideoPlayerVC: VideoPlayerViewDelegate {
    
    func videoPlayerDidPause(_ videoPlayer: VideoPlayerView) {
        self.presenter?.videoDidPause()
    }
    
    func videoPlayerDidStart(_ videoPlayer: VideoPlayerView) {
        self.presenter?.videoDidStart()
    }
    
    func videoPlayerDidStop(_ videoPlayer: VideoPlayerView) {
       self.presenter?.videoDidStop()
    }
    
    func videoPlayerDidFinish(_ videoPlayer: VideoPlayerView) {
        self.presenter?.dismiss()
    }
}

// MARK: - VideoPlayerUI

extension VideoPlayerVC: VideoPlayerUI {
    
    func showLoadingIndicator() {
        self.activityIndicator?.startAnimating()
    }
    
    func dismissLoadingIndicator() {
        self.activityIndicator?.stopAnimating()
    }
    
    func showVideoPlayer() {
        self.player?.show()
        if let activityIndicator = self.activityIndicator {
            self.view.bringSubview(toFront: activityIndicator)
        }
    }
    
    func startVideo(_ url: URL) {
        self.player?.url = url
        self.player?.play()
    }
}
