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
    var player: VideoPlayer?
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator = UIActivityIndicatorView()
        self.activityIndicator?.hidesWhenStopped = true
        self.player = VideoPlayer(showingIn: self, with: self.view.bounds)
        self.player?.delegate = self
        if let activityIndicator = self.activityIndicator {
            self.view.addSubview(activityIndicator, settingAutoLayoutOptions: [
                .centerY(to: self.view),
                .centerX(to: self.view)
            ])
        }
        self.presenter?.viewDidLoad()
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
        self.activityIndicator?.startAnimating()
    }
    
    func dismissLoadingIndicator() {
        self.activityIndicator?.stopAnimating()
    }
    
    func showVideoPlayer() {
        self.player?.showPlayer()
        if let activityIndicator = self.activityIndicator {
            self.view.bringSubview(toFront: activityIndicator)
        }
    }
    
    func startVideo(_ url: URL) {
        self.player?.play(with: url)
    }
}
