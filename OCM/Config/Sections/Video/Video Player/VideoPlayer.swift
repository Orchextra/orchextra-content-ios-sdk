//
//  VideoPlayer.swift
//  OCM
//
//  Created by José Estela on 9/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit

protocol VideoPlayerDelegate: class {
    func videoPlayerDidFinish(_ videoPlayer: VideoPlayer)
}

class VideoPlayer: UIView {
    
    // MARK: - Public attributes
    
    weak var delegate: VideoPlayerDelegate?
    
    // MARK: - Private attributes
    
    private var playerViewController: AVPlayerViewController?
    private weak var containerViewController: UIViewController?
    private var obs: NSKeyValueObservation?
    
    // MARK: - Public methods
    
    init(showingIn viewController: UIViewController, with frame: CGRect) {
        self.containerViewController = viewController
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func play(with url: URL) {
        let player = AVPlayer(url: url)
        self.playerViewController = AVPlayerViewController()
        self.playerViewController?.player = player
        if let playerViewController = self.playerViewController {
            playerViewController.view.frame = self.bounds
            self.containerViewController?.addChildViewController(playerViewController)
            self.containerViewController?.view.addSubview(playerViewController.view)
            playerViewController.didMove(toParentViewController: self.containerViewController)
            self.obs = player.observe(\.rate) { [unowned self] object, _ in
                if object.rate == 0 {
                    self.delegate?.videoPlayerDidFinish(self)
                }
            }
            player.play()
        }
    }
}
