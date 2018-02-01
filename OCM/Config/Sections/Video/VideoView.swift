//
//  VideoView.swift
//  OCM
//
//  Created by José Estela on 5/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

protocol VideoViewDelegate: class {
    func didTapVideo(_ video: Video)
    func videoPlayerDidExitFromFullScreen(_ videoPlayer: VideoPlayer)
    func videoShouldSound() -> Bool?
    func enableSound()
}

class VideoView: UIView {
    
    // MARK: - Private attributes
    
    var video: Video?
    let reachability = ReachabilityWrapper.shared
    var bannerView: BannerView?
    var isEnabled = true
    weak var delegate: VideoViewDelegate?
    private var videoPreviewImageView: URLImageView?
    var videoPlayer: VideoPlayerProtocol?
    private var videoPlayerContainerView: UIView?
    var soundButton: UIButton? //!!!
    
    // MARK: - Initializers
    
    init(video: Video, frame: CGRect) {
        self.video = video
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.video = nil
        super.init(coder: aDecoder)
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.backgroundColor = UIColor.red
        addSubview(button)
    }
    
    func addVideoPreview() {
        
        self.videoPreviewImageView = URLImageView(frame: .zero)
        guard let videoPreviewImageView = self.videoPreviewImageView else { logWarn("videoPreviewImageView is nil"); return }
        self.addSubview(videoPreviewImageView)
        
        let imagePlayPreview = UIImageView(frame: CGRect.zero)
        imagePlayPreview.translatesAutoresizingMaskIntoConstraints = false
        imagePlayPreview.image = UIImage.OCM.playIconPreviewView
        self.addSubview(imagePlayPreview)
        imagePlayPreview.set(autoLayoutOptions: [
            .centerX(to: self),
            .centerY(to: self),
            .height(65),
            .width(65)
        ])
        
        videoPreviewImageView.translatesAutoresizingMaskIntoConstraints = false
        videoPreviewImageView.backgroundColor = UIColor(white: 0, alpha: 0.08)
        videoPreviewImageView.image = Config.styles.placeholderImage
        videoPreviewImageView.contentMode = .scaleAspectFill
        videoPreviewImageView.clipsToBounds = true
        videoPreviewImageView.set(autoLayoutOptions: [
            .width(UIScreen.main.bounds.width),
            .aspectRatio(width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.width * 9) / 16),
            .margin(to: self, top: 0, bottom: 0, left: 8, right: 8)
        ])
        
        // Add a banner when there isn't internet connection
        if !self.reachability.isReachable() {
            self.bannerView = BannerView()
            self.bannerView?.message = Config.strings.internetConnectionRequired
            if let bannerView = self.bannerView {
                self.addSubview(bannerView, settingAutoLayoutOptions: [
                    .margin(to: self, top: 8, left: 8, right: 8),
                    .height(50)
                ])
                bannerView.layoutIfNeeded()
                bannerView.setup()
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapPreview(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    func update(with video: Video) {
        self.video = video
        self.loadPreview()
    }
    
    func isVideoVisible() -> Bool {
        return self.isVisible()
    }
    
    // MARK: Action
    
    @objc func tapPreview(_ sender: UITapGestureRecognizer) {
        guard let video = self.video else { logWarn("video is nil"); return }
        self.delegate?.didTapVideo(video)
    }
    @objc func didTapOnSoundButton() {
        self.delegate?.enableSound()
        self.videoPlayer?.enableSound(self.delegate?.videoShouldSound() ?? false)
        self.updateSoundButton()
    }
    
    func addVideoPlayer() {
        guard let videoURLPath = self.video?.videoUrl,
            let videoURL = URL(string: videoURLPath),
            let videoPreviewImageView = self.videoPreviewImageView else {
                return
        }
        if self.videoPlayer == nil {
            let videoPlayerContainerView = UIView(frame: videoPreviewImageView.frame)
            self.videoPlayerContainerView = videoPlayerContainerView
            if ReachabilityWrapper.shared.isReachableViaWiFi() {
                self.addSubview(videoPlayerContainerView, settingAutoLayoutOptions: [
                    .height(videoPreviewImageView.height()),
                    .width(videoPreviewImageView.width()),
                    .centerY(to: self),
                    .centerX(to: self)
                    ])
                
                let soundOn = self.delegate?.videoShouldSound() ?? false
                let videoPlayer = VideoPlayer(frame: videoPlayerContainerView.frame, url: videoURL, muted: !soundOn)
                videoPlayer.isUserInteractionEnabled = false
                videoPlayerContainerView.addSubviewWithAutolayout(videoPlayer)
                self.videoPlayer = videoPlayer
                self.videoPlayer?.delegate = self
                self.setupSoundButton()
            } else {
                videoPreviewImageView.addSubviewWithAutolayout(videoPlayerContainerView)
            }
        }
    }
    
    func play() {
        if ReachabilityWrapper.shared.isReachableViaWiFi() {
            self.videoPlayer?.play()
            let soundOn = self.delegate?.videoShouldSound() ?? false
            self.videoPlayer?.enableSound(soundOn)
            self.updateSoundButton()
        }
    }
    
    func pause() {
        self.videoPlayer?.pause()
        self.soundButton?.isHidden = true
    }
    
    func isPlaying() -> Bool {
        return self.videoPlayer?.isPlaying() ?? false
    }
    
    // MARK: - Private methods
    
    private func setupSoundButton() {
        let soundButton = UIButton(frame: CGRect.zero)
        self.soundButton = soundButton
        soundButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnSoundButton)))
        soundButton.layer.masksToBounds = true
        soundButton.layer.cornerRadius = 20
        soundButton.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        soundButton.translatesAutoresizingMaskIntoConstraints = false
        soundButton.setImage(self.soundButtonIcon(), for: .normal)
        
        if let videoPlayerContainerView = self.videoPlayerContainerView {
            videoPlayerContainerView.addSubview(soundButton)
            gig_autoresize(soundButton, false)
            gig_constrain_height(soundButton, 40)
            gig_constrain_width(soundButton, 40)
            gig_layout_left(soundButton, 10)
            gig_layout_bottom(soundButton, 10)
        }
    }
    
    private func updateSoundButton() {
        self.soundButton?.isHidden = false
        self.soundButton?.setImage(self.soundButtonIcon(), for: .normal)
    }
    
    private func soundButtonIcon() -> UIImage? {
        if let soundOn = self.delegate?.videoShouldSound(), soundOn {
            return UIImage.OCM.soundOnButtonIcon
        } else {
            return UIImage.OCM.soundOffButtonIcon
        }
    }
    
    private func loadPreview() {
        if let previewUrl = self.video?.previewUrl {
            ImageDownloadManager.shared.downloadImage(with: previewUrl, completion: { (image, _) in
                if let image = image {
                    self.videoPreviewImageView?.image = image
                }
            })
        }
    }
}

// MARK: - VideoPlayerDelegate

extension VideoView: VideoPlayerDelegate {
    
    func videoPlayerDidFinish(_ videoPlayer: VideoPlayer) {
        // Todo nothing
    }
    
    func videoPlayerDidStart(_ videoPlayer: VideoPlayer) {
        // Todo nothing
    }
    
    func videoPlayerDidStop(_ videoPlayer: VideoPlayer) {
        // Todo nothing
    }
    
    func videoPlayerDidPause(_ videoPlayer: VideoPlayer) {
        // Todo nothing
    }
    
    func videoPlayerDidExitFromFullScreen(_ videoPlayer: VideoPlayer) {
        self.delegate?.videoPlayerDidExitFromFullScreen(videoPlayer)
    }
}
