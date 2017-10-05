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
    
    // MARK: - Outlets
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backButton: UIButton!
    
    // MARK: - Attributtes
    
    var presenter: VideoPlayerPresenter?
    var player: AVPlayer?
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backButton.setCornerRadius(self.backButton.frame.size.height / 2)
        self.activityIndicator.color = Config.styles.primaryColor
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
        self.activityIndicator.startAnimating()
    }
    
    func dismissLoadingIndicator() {
        self.activityIndicator.stopAnimating()
    }
}

extension VideoPlayerVC: Instantiable {
    
    // MARK: - Instantiable
    
    static var storyboard = "Video"
    static var identifier = "VideoPlayerVC"
}
