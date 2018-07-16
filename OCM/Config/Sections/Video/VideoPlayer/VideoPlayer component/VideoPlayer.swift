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
    
    private var isFullscreen: Bool
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var videoIdentifier: String?
    private var isShown = false
    private weak var containerViewController: UIViewController?
    
    // MARK: - Public methods
    
    init(frame: CGRect, url: URL? = nil, muted: Bool) {
        self.url = url
        if let url = self.url {
            self.player = AVPlayer(url: url)
            self.player?.isMuted = muted
        }
        self.videoIdentifier = self.url?.absoluteString
        self.isFullscreen = false
        super.init(frame: frame)
        self.containerViewController = self.topViewController()
    }
    
    private init(inFullscreen fullscreen: Bool) {
        self.isFullscreen = fullscreen
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func fullscreenPlayer(in viewController: UIViewController) -> VideoPlayer {
        let videoPlayer = VideoPlayer(inFullscreen: true)
        videoPlayer.containerViewController = viewController
        return videoPlayer
    }
    
    // MARK: - VideoPlayerProtocol
    
    func show() {
        if !isShown && !isFullscreen {
            let playerLayer = AVPlayerLayer(player: self.player)
            playerLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            playerLayer.backgroundColor = UIColor.black.cgColor
            self.layer.addSublayer(playerLayer)
            self.playerLayer = playerLayer
            self.isShown = true
        } else if let url = self.url, !isShown, isFullscreen {
            let fullscreenPlayer = FullScreenVideoPlayerController()
            fullscreenPlayer.playerLayer = AVPlayerLayer(player: AVPlayer(url: url))
            fullscreenPlayer.dismissCompletion = { [weak self] _ in
                guard let weakSelf = self else { return }
                weakSelf.delegate?.videoPlayerDidFinish(weakSelf)
            }
            fullscreenPlayer.statusChangeHandler = handleVideoStatusChange
            self.containerViewController?.present(fullscreenPlayer, animated: false) {
                fullscreenPlayer.playerLayer.player?.play()
            }
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
        let fullscreenPlayer = FullScreenVideoPlayerController()
        fullscreenPlayer.dismissCompletion = { [weak self] playerLayer in
            guard let weakSelf = self else { return }
            playerLayer.frame = CGRect(x: 0, y: 0, width: weakSelf.frame.size.width, height: weakSelf.frame.size.height)
            weakSelf.layer.addSublayer(playerLayer)
            weakSelf.delegate?.videoPlayerDidExitFromFullScreen(weakSelf)
            playerLayer.backgroundColor = UIColor.black.cgColor
        }
        fullscreenPlayer.statusChangeHandler = handleVideoStatusChange
        fullscreenPlayer.playerLayer = self.playerLayer
        self.containerViewController?.present(fullscreenPlayer, animated: false) {
            fullscreenPlayer.playerLayer.player?.play()
            completion?()
        }
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
    
    // MARK: - Private methods
    
    private func handleVideoStatusChange(_ videoStatus: VideoStatus) {
        self.status = videoStatus
        switch videoStatus {
        case .paused:
            self.delegate?.videoPlayerDidPause(self)
        case .playing:
            self.delegate?.videoPlayerDidStart(self)
        case .stop:
            self.delegate?.videoPlayerDidStop(self)
        default:
            break
        }
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
}

private class FullScreenVideoPlayerController: UIViewController, VideoPlayerControlsDelegate {
    
    // MARK: - Public attributes
    
    weak var playerLayer: AVPlayerLayer!
    var dismissCompletion: ((AVPlayerLayer) -> Void)?
    var statusChangeHandler: ((VideoStatus) -> Void)?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    deinit {
        self.unregisterFromNotifications()
    }
    
    // MARK: - Private attributes
    
    private var controls: VideoPlayerControls?
    private var headerView: TouchableView?
    private var playerOverlayView: TouchableView?
    private var playbackTimeObserver: Any?
    private var pauseObservation: NSKeyValueObservation?
    private var currentVideoStatus: VideoStatus = .undefined
    fileprivate var observers =  [NSObjectProtocol]()
    fileprivate lazy var notificationsQueue: OperationQueue = {
        return OperationQueue()
    }()
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let playerView = UIView()
        self.setupPlayer()
        if let item = self.playerLayer.player?.currentItem {
            let imageGenerator = AVAssetImageGenerator(asset: item.asset)
            if let cgImage = try? imageGenerator.copyCGImage(at: item.currentTime(), actualTime: nil) {
                let imageView = UIImageView(image: UIImage(cgImage: cgImage))
                let blurEffect = UIBlurEffect(style: .dark)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                imageView.addSubview(blurEffectView, settingAutoLayoutOptions: [
                    .margin(to: imageView, top: 0, bottom: 0, left: 0, right: 0, safeArea: false)
                ])
                playerView.addSubview(imageView, settingAutoLayoutOptions: [
                    .margin(to: playerView, top: 0, bottom: 0, left: 0, right: 0, safeArea: false)
                ])
            }
        }
        playerView.layer.addSublayer(self.playerLayer)
        self.view.addSubview(playerView, settingAutoLayoutOptions: [
            .margin(to: self.view, top: 0, bottom: 0, left: 0, right: 0, safeArea: false)
        ])
        if let item = self.playerLayer.player?.currentItem {
            self.registerForNotifications(with: item)
        }
        self.setupOverlay()
        self.setupHeader(in: self.preferredInterfaceOrientationForPresentation)
        self.setupPlayerControls()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        self.playerLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
        self.setupHeader(in: toInterfaceOrientation)
    }
    
    // MARK: - Private methods
    
    private func dismiss() {
        self.dismiss(animated: false) { [weak self] in
            guard let layer = self?.playerLayer else { return }
            self?.dismissCompletion?(layer)
        }
    }
    
    private func setupPlayer() {
        self.playerLayer.backgroundColor = UIColor.clear.cgColor
        self.playerLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    }
    
    private func setupOverlay() {
        let overlayView = TouchableView()
        self.view.addSubview(overlayView, settingAutoLayoutOptions: [
            .margin(to: self.view, top: 0, bottom: 0, left: 0, right: 0, safeArea: false)
        ])
        overlayView.addAction { [weak self] in
            guard let headerView = self?.headerView, let controls = self?.controls else { return }
            headerView.isHidden = !headerView.isHidden
            controls.isHidden = !controls.isHidden
        }
        self.playerOverlayView = overlayView
    }
    
    private func setupHeader(in orientation: UIInterfaceOrientation) {
        let headerView = TouchableView()
        self.setupHeaderSubviews(headerView, in: orientation)
        self.view.addSubview(headerView, settingAutoLayoutOptions: [
            .margin(to: self.view, top: 0, left: 0, right: 0, safeArea: false),
            .height(81)
        ])
        
        headerView.isHidden = self.headerView?.isHidden ?? true
        headerView.addAction { [weak self] in
            self?.dismiss()
        }
        self.headerView?.removeFromSuperview()
        self.headerView = headerView
    }
    
    private func setupHeaderSubviews(_ headerView: UIView, in orientation: UIInterfaceOrientation) {
        switch orientation {
        case .landscapeLeft, .landscapeRight:
            let backgroundBackView = UIView()
            backgroundBackView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
            backgroundBackView.layer.cornerRadius = 20
            backgroundBackView.layer.masksToBounds = true
            let backButton = UIImageView(image: UIImage.OCM.backButtonIcon)
            headerView.addSubview(backgroundBackView, settingAutoLayoutOptions: [
                .margin(to: headerView, left: 20, safeArea: false),
                .width(40),
                .height(40),
                .centerY(to: headerView)
            ])
            backgroundBackView.addSubview(backButton, settingAutoLayoutOptions: [
                .width(20),
                .height(20),
                .centerY(to: backgroundBackView),
                .centerX(to: backgroundBackView)
            ])
        default:
            headerView.backgroundColor = Config.styles.primaryColor
            let headerImage = UIImageView(image: Config.contentNavigationBarStyles.barBackgroundImage)
            let backButton = UIImageView(image: UIImage.OCM.backButtonIcon)
            headerView.addSubview(headerImage, settingAutoLayoutOptions: [
                .margin(to: headerView, top: 0, bottom: 0, left: 0, right: 0, safeArea: false)
            ])
            headerView.addSubview(backButton, settingAutoLayoutOptions: [
                .margin(to: headerView, top: 5, left: 20, safeArea: true),
                .width(20),
                .height(20)
            ])
        }
    }
    
    private func setupPlayerControls() {
        guard let controls = VideoPlayerControls.instantiate(), let playerItem = self.playerLayer.player?.currentItem else { return }
        controls.delegate = self
        controls.set(videoDuration: Int(playerItem.asset.duration.seconds))
        controls.set(currentTime: 0)
        self.view.addSubview(controls, settingAutoLayoutOptions: [
            .margin(to: self.view, bottom: 0, left: 0, right: 0, safeArea: false),
            .height(80)
        ])
        controls.isHidden = true
        self.controls = controls
        self.pauseObservation = self.playerLayer.player?.observe(\.rate, options: [.new], changeHandler: { [unowned self] (thePlayer, _) in
            if thePlayer.rate == 0.0 {
                self.pauseTimer()
                self.currentVideoStatus = .paused
            } else {
                self.startTimer()
                self.currentVideoStatus = .playing
            }
            self.controls?.set(videoStatus: self.currentVideoStatus)
            self.statusChangeHandler?(self.currentVideoStatus)
        })
    }
    
    private func startTimer() {
        self.playbackTimeObserver = self.playerLayer.player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1, preferredTimescale: 2),
            queue: .main
        ) { [weak self] _ in
            guard let seconds = self?.playerLayer.player?.currentItem?.currentTime().seconds else { return }
            self?.controls?.set(currentTime: Int(seconds))
        }
    }
    
    private func pauseTimer() {
        guard let playbackTimeObserver = self.playbackTimeObserver else { return }
        self.playerLayer.player?.removeTimeObserver(playbackTimeObserver)
    }
    
    private func registerForNotifications(with playerItem: AVPlayerItem) {
        let stopObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem, queue: self.notificationsQueue) { [unowned self] (_) in
            DispatchQueue.main.async {
                self.currentVideoStatus = .stop
                self.statusChangeHandler?(self.currentVideoStatus)
                self.dismiss()
            }
        }
        let playingErrorObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: playerItem, queue: self.notificationsQueue) { [unowned self] (_) in
            DispatchQueue.main.async {
                self.currentVideoStatus = .stop
                self.statusChangeHandler?(self.currentVideoStatus)
                self.dismiss()
            }
        }
        let orientationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIDeviceOrientationDidChange, object: nil, queue: self.notificationsQueue) {  _ in
            FullScreenVideoPlayerController.attemptRotationToDeviceOrientation()
        }
        self.observers = [stopObserver, playingErrorObserver, orientationObserver]
    }
    
    private func unregisterFromNotifications() {
        for observer in self.observers {
            NotificationCenter.default.removeObserver(observer)
        }
        self.observers.removeAll()
    }
    
    // MARK: - VideoPlayerControlsDelegate
    
    func videoPlayerControlDidTapPlayPauseButton() {
        switch self.currentVideoStatus {
        case .playing:
            self.playerLayer.player?.pause()
        default:
            self.playerLayer.player?.play()
        }
    }
    
    func videoPlayerControlDidChangeCurrentState(to value: Float) {
        self.playerLayer.player?.currentItem?.seek(
            to: CMTime(
                seconds: TimeInterval(value),
                preferredTimescale: CMTimeScale(NSEC_PER_SEC)
            )
        )
    }
}
