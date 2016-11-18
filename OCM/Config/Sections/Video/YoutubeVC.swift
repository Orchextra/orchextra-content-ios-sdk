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
    
    let youtubePlayer = YTPlayerView()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.youtubePlayer.delegate = self
        self.view.addSubviewWithAutolayout(self.youtubePlayer)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidTapDoneButton),
            name: Notification.Name(rawValue: "UIWindowDidBecomeHiddenNotification"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - PUBLIC
    
    func loadVideo(id: String) {
        
        let playerVars = [
            "origin" : "http://www.youtube.com",
            "autoplay": 1
            ] as [String : Any]
        
        self.youtubePlayer.load(withVideoId: id, playerVars: playerVars)
    }
    
    // MARK: - YTPlayerViewDelegate
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        self.youtubePlayer.playVideo()
    }
    
    // MARK: - PRIVATE
    
    @objc private func userDidTapDoneButton() {
        let _ = self.dismiss(animated: true, completion: nil)
    }
}
