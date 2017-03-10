//
//  YoutubeVC.swift
//  OCM
//
//  Created by Sergio López on 18/11/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import YouTubeiOSPlayerHelper

class YoutubeVC: OrchextraViewController, YTPlayerViewDelegate {
    
    @IBOutlet weak var youtubePlayer: YTPlayerView!
    var isInitialStatusBarHidden: Bool = false
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.youtubePlayer.delegate = self
        self.isInitialStatusBarHidden = UIApplication.shared.isStatusBarHidden
        
        self.youtubePlayer.webView?.allowsInlineMediaPlayback = true
        self.youtubePlayer.webView?.mediaPlaybackRequiresUserAction = false
        self.youtubePlayer.isUserInteractionEnabled = false
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidTapDoneButton),
            name: Notification.Name(rawValue: "UIWindowDidBecomeHiddenNotification"),
            object: nil
        )
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
        let _ = self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - PUBLIC
    
    func loadVideo(id: String) {
        
        let playerVars = [
            "controls": 1,
            "playsinline": 0,
            "autohide": 0,
            "showinfo": 0,
            "origin": "http://www.youtube.com",
            "modestbranding": 1
            ] as [String : Any]
        
        self.youtubePlayer.load(withVideoId: id, playerVars: playerVars)
    }
    
    // MARK: - YTPlayerViewDelegate
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        self.youtubePlayer.playVideo()
    }
    
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        let _ = self.dismiss(animated: true, completion: nil)
    }
    // MARK: - PRIVATE
    
    @objc private func userDidTapDoneButton() {
        let _ = self.dismiss(animated: true, completion: nil)
    }
}
