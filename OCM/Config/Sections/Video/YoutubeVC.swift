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
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.youtubePlayer.delegate = self
        
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
    
    // MARK: - Actions
    
    @IBAction func didTap(_ sender: UIButton) {
        let _ = self.dismiss(animated: true, completion: nil)
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
    
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        let _ = self.dismiss(animated: true, completion: nil)
    }
    // MARK: - PRIVATE
    
    @objc private func userDidTapDoneButton() {
        let _ = self.dismiss(animated: true, completion: nil)
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeLeft
    }
}
