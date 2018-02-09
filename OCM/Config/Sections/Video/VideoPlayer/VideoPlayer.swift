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
    
    weak var delegate: VideoPlayerDelegate? { get set }
    
    func show()
    func play()
    func pause()
    func isPlaying() -> Bool
    func toFullScreen(_ completion: (() -> Void)?)
    func enableSound(_ enable: Bool)
    func videoStatus() -> VideoStatus
}

class VideoPlayer: UIView {
    
    // MARK: - Private attributes
    
    fileprivate var observers =  [NSObjectProtocol]()
    fileprivate lazy var notificationsQueue: OperationQueue = {
        return OperationQueue()
    }()
    private var playerViewController: VideoPlayerController?
    private var player: AVPlayer?
    private var pauseObservation: NSKeyValueObservation?
    private var closeObservation: NSKeyValueObservation?
    private var statusObservation: NSKeyValueObservation?
    private var isInFullScreen = false
    private var isShowed = false
    /// `true` when the video is entering fullscreen mode from the video preview (autoplay), `false` otherwise
    private var didEnterFullScreenMode = false
    private var videoIdentifier: String?
    private weak var containerViewController: UIViewController?
    
    // MARK: - Public attributes
    
    weak var delegate: VideoPlayerDelegate?
    var url: URL? {
        didSet {
            self.videoIdentifier = self.url?.absoluteString
        }
    }
    var status: VideoStatus = .undefined
    
    // MARK: - View life cycle
    
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
    
    deinit {
        self.unregisterFromNotifications()
    }
    
    class func fullScreenPlayer(url: URL? = nil) -> VideoPlayer {
        let videoPlayer = VideoPlayer(frame: UIScreen.main.bounds, url: url, muted: false)
        videoPlayer.isInFullScreen = true
        videoPlayer.containerViewController = videoPlayer.topViewController()
        return videoPlayer
    }
    
    class func fullScreenPlayer(in viewController: UIViewController, url: URL? = nil) -> VideoPlayer {
        let videoPlayer = VideoPlayer(frame: viewController.view.frame, url: url, muted: false)
        videoPlayer.containerViewController = viewController
        videoPlayer.isInFullScreen = true
        return videoPlayer
    }    
}

// MARK: - VideoPlayerProtocol

extension VideoPlayer: VideoPlayerProtocol {
    
    func show() {
        self.playerViewController = VideoPlayerController()
        if self.isInFullScreen {
            if let playerViewController = self.playerViewController, let containerViewController = self.containerViewController {
                playerViewController.view.frame = self.bounds
                containerViewController.addChildViewController(playerViewController)
                containerViewController.view.addSubview(playerViewController.view)
                playerViewController.didMove(toParentViewController: containerViewController)
                self.isShowed = true
            }
        } else if self.url != nil {
            if let playerViewController = self.playerViewController {
                playerViewController.showsPlaybackControls = false
                playerViewController.view.frame = self.frame
                self.addSubviewWithAutolayout(playerViewController.view)
                self.isShowed = true
            }
        }
    }
    
    func play() {
        guard let url = self.url else { return logWarn("There is an error loading the url of the video") }
        self.play(inFullScreen: self.isInFullScreen, url: url)
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
    
    func toFullScreen(_ completion: (() -> Void)? = nil) {
        if self.isShowed && !self.isInFullScreen {
            self.enableSound(true)
            self.isInFullScreen = true
            self.didEnterFullScreenMode = true
            if #available(iOS 11.0, *) {
                self.playerViewController?.exitsFullScreenWhenPlaybackEnds = true
            }
            self.playerViewController?.toFullScreen {
                self.playerViewController?.showsPlaybackControls = true
            }
            self.playerViewController?.exitFullScreenCompletion = { [unowned self] in
                self.didExitFromFullScreen()
            }
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
}

// MARK: - Private methods

private extension VideoPlayer {

    func videoDidStart() {
        if #available(iOS 10.0, *) {
            // KVO para detectar cuando cambia el estado de la reproducción (start / pause)
            self.pauseObservation = self.player?.observe(\.timeControlStatus, options: [.new], changeHandler: { [unowned self] (thePlayer, _) in
                switch thePlayer.timeControlStatus {
                case .playing:
                    self.status = .playing
                    self.delegate?.videoPlayerDidStart(self)
                case .paused:
                    // HOTFIX: We added this hack in order to fix a AVPlayer bug when you close the view (we receive the same event than the pause button tap)
                    // READ: https://stackoverflow.com/questions/48021088/avplayerviewcontroller-doesnt-maintain-play-pause-state-while-returning-from-fu
                    // Refactor once this bug is fixed on iOS 11
                    if #available(iOS 11, *), let videoIdentifier = self.videoIdentifier, self.didEnterFullScreenMode {
                        if self.isInFullScreen {
                            TimerActionScheduler.shared.registerAction(identifier: "\(videoIdentifier).paused", executeAfter: 1.0) { [unowned self] in
                                self.status = .playing
                            }
                            TimerActionScheduler.shared.start("\(videoIdentifier).paused")
                        } else if self.status == .playing {
                            // If the video is paused in small screen and it is not triggered by the public method pause(). We assume that this event occurs when the user close the player with the swipe movement.
                            self.play()
                        }
                    }
                    self.status = .paused
                    self.delegate?.videoPlayerDidPause(self)
                default:
                    break
                }
            })
        } else {
            self.delegate?.videoPlayerDidStart(self)
        }
    }
    
    func unregisterFromNotifications() {
        for observer in self.observers {
            NotificationCenter.default.removeObserver(observer)
        }
        self.observers.removeAll()
    }
    
    func registerForNotifications(with playerItem: AVPlayerItem) {
        //Notificación que es lanzada cuando la reproducción del item finaliza de forma correcta
        let stopObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem, queue: self.notificationsQueue) { [unowned self] (_) in
            DispatchQueue.main.async {
                self.notifyVideoStop()
            }
        }
        //Notificación que se lanza cuando se produce algún error en la reproducción del item
        let playingErrorObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: playerItem, queue: self.notificationsQueue) { [unowned self] (_) in
            DispatchQueue.main.async {
                self.notifyVideoStop()
            }
        }
        self.observers = [stopObserver, playingErrorObserver]
    }
    
    func notifyVideoStop() {
        self.status = .stop
        self.delegate?.videoPlayerDidStop(self)
        self.playerViewController?.removeFromParentViewController()
    }
    
    func play(inFullScreen fullscreen: Bool, url: URL) {
        if !self.isPlaying() {
            if !self.isShowed {
                self.show()
            }
            if self.player == nil {
                let playerItem = AVPlayerItem(url: url)
                self.player = AVPlayer(playerItem: playerItem)
                self.playerViewController?.player = self.player
            } else {
                self.playerViewController?.player = self.player
            }
            if fullscreen {
                // KVO para detectar cuando se pulsa el botón de cierre (X)
                self.closeObservation = self.player?.observe(\.rate, changeHandler: { [unowned self] (thePlayer, _) in
                    if thePlayer.rate == 0.0, let containerViewController = self.containerViewController, containerViewController.isBeingDismissed {
                        // Con esta condición se comprueba si la reproducción del item no ha finalizado (usuario cierra la ventana sin esperar el final del video)
                        // Si se quita se producen dos eventos stop ya que el evento de video finalizado se gestiona en la notificación AVPlayerItemDidPlayToEndTime
                        if let playerItem = thePlayer.currentItem, playerItem.duration > thePlayer.currentTime() {
                            DispatchQueue.main.async {
                                self.notifyVideoStop()
                            }
                        }
                    }
                })
            }
            unregisterFromNotifications()
            if let player = self.player, let item = player.currentItem {
                registerForNotifications(with: item)
            }
            self.player?.play()
            self.status = .playing
            self.videoDidStart()
        }
    }
    
    func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
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
    
    func didExitFromFullScreen() {
        // HOTFIX: We added this hack in order to fix a AVPlayer bug when you close the view (we receive the same event than the pause button tap)
        // READ: https://stackoverflow.com/questions/48021088/avplayerviewcontroller-doesnt-maintain-play-pause-state-while-returning-from-fu
        // Refactor once this bug is fixed on iOS 11
        if #available(iOS 11, *), let videoIdentifier = self.videoIdentifier {
            TimerActionScheduler.shared.stop("\(videoIdentifier).paused")
        }
        self.delegate?.videoPlayerDidExitFromFullScreen(self)
        self.playerViewController?.showsPlaybackControls = false
        self.didEnterFullScreenMode = false
        self.isInFullScreen = false
    }
}

private class VideoPlayerController: AVPlayerViewController {
    
    // MARK: - Public attributes
    
    var exitFullScreenCompletion: (() -> Void)?
    
    // MARK: - View life cycle
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let overlayView = self.contentOverlayView else { return }
        // iPhone X
        if #available(iOS 11.0, *), let saveAreas = UIApplication.shared.keyWindow?.safeAreaInsets, saveAreas.top > 0.0 {
            let screen = UIScreen.main.bounds
            if overlayView.bounds.height <= screen.height - saveAreas.top - saveAreas.bottom {
                self.exitFullScreenCompletion?()
            }
        } else if overlayView.bounds != UIScreen.main.bounds {
            self.exitFullScreenCompletion?()
        }
    }
    
    // MARK: - Public methods
    
    func toFullScreen(_ completion: (() -> Void)?) {
        // !!! -> Maybe Apple reject the app because of this
        let selectorName: String = {
            if #available(iOS 11, *) {
                return "_transitionToFullScreenAnimated:completionHandler:"
            } else {
                return "_transitionToFullScreenViewControllerAnimated:completionHandler:"
            }
        }()
        let selector = NSSelectorFromString(selectorName)
        if self.responds(to: selector) {
            self.perform(selector, with: true, with: nil)
        }
        completion?()
    }
}
