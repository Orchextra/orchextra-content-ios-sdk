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

class VideoPlayerVC: AVPlayerViewController {
    
    // MARK: - Attributtes
    
    var presenter: VideoPlayerPresenter?
    var activityIndicator: UIActivityIndicatorView?
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator = UIActivityIndicatorView()
        self.activityIndicator?.hidesWhenStopped = true
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
    
    func startVideo(_ video: Video) {
        if let videoURL = video.videoUrl, let url = URL(string: videoURL) {
            self.player = AVPlayer(url: url)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = self.player
            self.present(playerViewController, animated: true) {
                self.player?.play()
            }
        } else {
            self.presenter?.dismiss()
        }
    }
}

extension VideoPlayerVC: VideoPlayerUI {
    
    func showLoadingIndicator() {
        self.activityIndicator?.startAnimating()
    }
    
    func dismissLoadingIndicator() {
        self.activityIndicator?.stopAnimating()
    }
}
