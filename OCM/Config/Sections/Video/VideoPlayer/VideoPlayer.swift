//
//  VideoPlayer.swift
//  OCM
//
//  Created by José Estela on 26/1/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import GIGLibrary

enum VideoStatus {
    case playing
    case stop
    case paused
    case undefined
}

protocol VideoPlayerDelegate: class {
    func videoPlayerDidFinish(_ videoPlayer: VideoPlayer)
    func videoPlayerDidStart(_ videoPlayer: VideoPlayer)
    func videoPlayerDidStop(_ videoPlayer: VideoPlayer)
    func videoPlayerDidPause(_ videoPlayer: VideoPlayer)
    func videoPlayerDidExitFromFullScreen(_ videoPlayer: VideoPlayer)
}

protocol VideoPlayerProtocol: class {
    var delegate: VideoPlayerDelegate? { get set }
    func show()
    func play()
    func pause()
    func isPlaying() -> Bool
    func toFullScreen(_ completion: (() -> Void)?)
    func enableSound(_ enable: Bool)
    func videoStatus() -> VideoStatus
}

class VideoPlayer: UIView, VideoPlayerProtocol {
    
    // MARK: - Public attributes
    
    weak var delegate: VideoPlayerDelegate?
    var url: URL? {
        didSet {
            self.videoIdentifier = self.url?.absoluteString
        }
    }
    var status: VideoStatus = .undefined
    
    // MARK: - Private attributes
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var videoIdentifier: String?
    private var fullScreenPlayer: FullScreenVideoPlayer?
    private var isShown = false
    
    // MARK: - Public methods
    
    init(frame: CGRect, url: URL? = nil, muted: Bool) {
        self.url = url
        if let url = self.url {
            self.player = AVPlayer(url: url)
            self.player?.isMuted = muted
        }
        self.videoIdentifier = self.url?.absoluteString
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - VideoPlayerProtocol
    
    func show() {
        if !self.isShown {
            let playerLayer = AVPlayerLayer(player: self.player)
            playerLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            self.layer.addSublayer(playerLayer)
            self.playerLayer = playerLayer
            self.isShown = true
        }
    }
    
    func play() {
        guard self.url != nil else { return logWarn("There is an error loading the url of the video") }
        self.show()
        self.status = .playing
        self.player?.play()
    }
    
    func pause() {
        self.status = .paused
        self.player?.pause()
    }
    
    func isPlaying() -> Bool {
        if let videoPlayer = self.player {
            if #available(iOS 10.0, *) {
                return videoPlayer.timeControlStatus == .playing
            } else {
                return videoPlayer.rate != 0
            }
        }
        return false
    }
    
    func toFullScreen(_ completion: (() -> Void)?) {
        guard let playerLayer = self.playerLayer else { return }
        self.fullScreenPlayer = FullScreenVideoPlayer(playerLayer: playerLayer)
        self.fullScreenPlayer?.show(
            showCompletion: completion,
            dismissCompletion: { playerLayer in
                playerLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
                self.layer.addSublayer(playerLayer)
            }
        )
    }
    
    func enableSound(_ enable: Bool) {
        let audioSession = AVAudioSession.sharedInstance()
        if enable {
            self.player?.isMuted = false
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            } catch {
                LogInfo("Updating AVAudioSeesion category to AVAudioSessionCategoryPlayback failed")
            }
        } else {
            self.player?.isMuted = true
            do {
                try audioSession.setCategory(AVAudioSessionCategorySoloAmbient)
            } catch {
                LogInfo("Updating AVAudioSeesion category to AVAudioSessionCategorySoloAmbient failed")
            }
        }
    }
    
    func videoStatus() -> VideoStatus {
        return self.status
    }
}

class FullScreenVideoPlayer {
    
    // MARK: - Private attributes
    
    private var playerLayer: AVPlayerLayer?
    private var url: URL?
    private var playerViewController: PlayerViewController?
    fileprivate var dismissCompletion: ((AVPlayerLayer) -> Void)?
    
    // MARK: - Public methods
    
    init(url: URL) {
        self.url = url
        self.playerLayer = AVPlayerLayer(player: AVPlayer(url: url))
    }
    
    func show(completion: (() -> Void)?) {
        let playerVC = PlayerViewController()
        playerVC.playerLayer = self.playerLayer
        self.topViewController()?.present(playerVC, animated: false) {
            playerVC.playerLayer.player?.play()
            completion?()
        }
    }
    
    // MARK: - Private methods
    
    @IBAction private func dismiss(_ sender: UIButton) {
        self.playerViewController?.dismiss(animated: false, completion: nil)
    }
    
    private func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
    // MARK: - Fileprivate methods
    
    fileprivate init(playerLayer: AVPlayerLayer) {
        self.playerLayer = playerLayer
    }
    
    fileprivate func show(showCompletion: (() -> Void)?, dismissCompletion: @escaping (AVPlayerLayer) -> Void) {
        let playerVC = PlayerViewController()
        playerVC.playerLayer = self.playerLayer
        playerVC.modalPresentationStyle = .overCurrentContext
        playerVC.dismissCompletion = dismissCompletion
        self.topViewController()?.present(playerVC, animated: false) {
            
            showCompletion?()
        }
    }
}

private class PlayerViewController: UIViewController {
    
    private var initialPlayerFrame: CGRect?
    weak var playerLayer: AVPlayerLayer!
    var dismissCompletion: ((AVPlayerLayer) -> Void)?
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let playerView = UIView()
        playerView.backgroundColor = .clear
        self.setupPlayer()
        playerView.layer.addSublayer(self.playerLayer)
        self.view.addSubview(playerView, settingAutoLayoutOptions: [
            .margin(to: self.view, top: 0, bottom: 0, left: 0, right: 0, safeArea: false)
        ])
        self.setupHeader()
        CATransaction.begin()
        CATransaction.setAnimationDuration(1.0)
        self.playerLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        CATransaction.commit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func dismiss() {
        if let initialPlayerFrame = self.initialPlayerFrame {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.5)
            self.playerLayer.frame = initialPlayerFrame
            CATransaction.setCompletionBlock {
                self.dismiss(animated: false) {
                    self.dismissCompletion?(self.playerLayer)
                }
            }
            CATransaction.commit()
        } else {
            self.dismiss(animated: false) {
                self.dismissCompletion?(self.playerLayer)
            }
        }
    }
    
    // MARK: - Private methods
    
    func setupPlayer() {
        self.playerLayer.backgroundColor = UIColor.black.cgColor
        guard
            let layerParentView = self.playerLayer.superlayer?.delegate as? UIView,
            let layerSuperView = layerParentView.superview
        else {
            self.playerLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            return
        }
        self.playerLayer.frame = layerSuperView.convert(layerParentView.frame, to: nil)
        self.initialPlayerFrame = self.playerLayer.frame
    }
    
    func setupHeader() {
        let view = TouchableView()
        view.backgroundColor = Config.styles.primaryColor
        let headerImage = UIImageView(image: Config.contentNavigationBarStyles.barBackgroundImage)
        let backButton = UIImageView(image: UIImage.OCM.backButtonIcon)
        self.view.addSubview(view, settingAutoLayoutOptions: [
            .margin(to: self.view, top: 0, left: 0, right: 0, safeArea: false),
            .height(81)
        ])
        view.addSubview(headerImage, settingAutoLayoutOptions: [
            .margin(to: view, top: 0, bottom: 0, left: 0, right: 0, safeArea: false)
        ])
        view.addSubview(backButton, settingAutoLayoutOptions: [
            .margin(to: view, left: 20, safeArea: false),
            .width(20),
            .height(20),
            .centerY(to: view)
        ])
        view.addAction {
            self.dismiss()
        }
    }
}
