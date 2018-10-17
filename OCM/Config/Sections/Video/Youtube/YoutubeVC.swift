//
//  YoutubeVC.swift
//  OCM
//
//  Created by Sergio López on 18/11/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import YouTubeiOSPlayerHelper
import GIGLibrary

class YoutubeVC: OCMViewController {
    
    @IBOutlet weak var youtubePlayer: YTPlayerView!
    @IBOutlet weak var backButton: UIButton!
    
    var isInitialStatusBarHidden: Bool = false
    var identifier: String = ""
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.youtubePlayer.delegate = self
        self.isInitialStatusBarHidden = UIApplication.shared.isStatusBarHidden
        
        self.youtubePlayer.webView?.allowsInlineMediaPlayback = true
        self.youtubePlayer.webView?.mediaPlaybackRequiresUserAction = false
        self.youtubePlayer.isUserInteractionEnabled = false
        
        let backImage = Config.contentNavigationBarStyles.backButtonImage ?? #imageLiteral(resourceName: "content_back_button")
        self.backButton.setImage(backImage, for: .normal)
        self.backButton.setCornerRadius(self.backButton.frame.size.height / 2)
        self.backButton.isHidden = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidTapDoneButton),
            name: Notification.Name(rawValue: "UIWindowDidBecomeHiddenNotification"),
            object: nil
        )
        
        let playerVars = [
            "controls": 1,
            "playsinline": 0,
            "autohide": 0,
            "showinfo": 0,
            "origin": "http://www.youtube.com",
            "modestbranding": 1
            ] as [String: Any]
        
        
        self.youtubePlayer.load(withVideoId: self.identifier, playerVars: playerVars)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.isStatusBarHidden = self.isInitialStatusBarHidden
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    
    @IBAction func didTap(_ sender: UIButton) {
        self.youtubePlayer.stopVideo()
        _ = self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Public methods
    
    func loadVideo(identifier: String) {
        self.identifier = identifier
    }
    
    // MARK: - Private methods
    
    @objc private func userDidTapDoneButton() {
        if youtubePlayer.duration() > TimeInterval(youtubePlayer.currentTime()) {
            notifyVideoDidStop(identifier: self.identifier)
        }
        _ = self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - YTPlayerViewDelegate

extension YoutubeVC: YTPlayerViewDelegate {
    
    // MARK: - YTPlayerViewDelegate
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        self.youtubePlayer.playVideo()
    }
    
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        _ = self.dismiss(animated: true, completion: nil)
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch state {
        case .unstarted:
            self.backButton.isHidden = false
        case .playing:
            self.notifyVideoDidStart(identifier: self.identifier)
        case .paused:
            self.notifyVideoDidPause(identifier: self.identifier)
        case .ended:
            self.notifyVideoDidStop(identifier: self.identifier)
        default:
            break
        }
    }
    
    private func notifyVideoDidStart(identifier: String) {
        if let videoEventDelegate = OCM.shared.videoEventDelegate {
            videoEventDelegate.videoDidStart(identifier: identifier)
        }
    }
    
    private func notifyVideoDidPause(identifier: String) {
        if let videoEventDelegate = OCM.shared.videoEventDelegate {
            videoEventDelegate.videoDidPause(identifier: identifier)
        }
    }
    
    private func notifyVideoDidStop(identifier: String) {
        if let videoEventDelegate = OCM.shared.videoEventDelegate {
            videoEventDelegate.videoDidStop(identifier: identifier)
        }
    }
    
}

// MARK: - Instantiable

extension YoutubeVC: Instantiable {
    
    static var storyboard = "Video"
    static var identifier = "YoutubeVC"
}
