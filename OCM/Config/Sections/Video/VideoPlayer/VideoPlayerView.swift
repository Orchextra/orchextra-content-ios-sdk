//
//  VideoPlayerView.swift
//  OCM
//
//  Created by José Estela on 26/1/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

protocol VideoPlayerViewDelegate: class {
    func videoPlayerDidFinish(_ videoPlayer: VideoPlayerView)
    func videoPlayerDidStart(_ videoPlayer: VideoPlayerView)
    func videoPlayerDidStop(_ videoPlayer: VideoPlayerView)
    func videoPlayerDidPause(_ videoPlayer: VideoPlayerView)
}

class VideoPlayerView: UIView {
    
    // MARK: - Private attributes
    
    fileprivate var observers =  [NSObjectProtocol]()
    fileprivate lazy var notificationsQueue: OperationQueue = {
        return OperationQueue()
    }()
    private var playerViewController: VideoPlayerViewController?
    private var player: AVPlayer?
    private var pauseObservation: NSKeyValueObservation?
    private var closeObservation: NSKeyValueObservation?
    private var changeFrameObservation: NSKeyValueObservation?
    private var isInFullScreen = false
    private var isShowed = false
    private var didEnterFullScreenMode = false
    private var containerViewController: UIViewController?
    
    // MARK: - Public attributes
    
    weak var delegate: VideoPlayerViewDelegate?
    var url: URL?
    
    // MARK: - View life cycle
    
    init(frame: CGRect, url: URL? = nil) {
        self.url = url
        if let url = self.url {
            self.player = AVPlayer(url: url)
        }
        super.init(frame: frame)
    }
    
    class func fullScreenPlayer(url: URL? = nil) -> VideoPlayerView {
        let videoPlayer = VideoPlayerView(frame: UIScreen.main.bounds, url: url)
        videoPlayer.isInFullScreen = true
        videoPlayer.containerViewController = videoPlayer.topViewController()
        return videoPlayer
    }
    
    class func fullScreenPlayer(in viewController: UIViewController, url: URL? = nil) -> VideoPlayerView {
        let videoPlayer = VideoPlayerView(frame: viewController.view.frame, url: url)
        videoPlayer.containerViewController = viewController
        videoPlayer.isInFullScreen = true
        return videoPlayer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        unregisterFromNotifications()
    }
    
    // MARK: - Public methods
    
    func show() {
        self.playerViewController = VideoPlayerViewController()
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
            self.isInFullScreen = true
            self.didEnterFullScreenMode = true
            if #available(iOS 11.0, *) {
                self.playerViewController?.exitsFullScreenWhenPlaybackEnds = true
            }
            self.playerViewController?.showsPlaybackControls = true
            self.playerViewController?.toFullScreen(completion)
            self.playerViewController?.exitFullScreenCompletion = {
                self.didExitFromFullScreen()
            }
        }
    }
}

// MARK: - Private methods

private extension VideoPlayerView {
    
    func videoDidStart() {
        if #available(iOS 10.0, *) {
            // KVO para detectar cuando cambia el estado de la reproducción (start / pause)
            self.pauseObservation = self.player?.observe(\.timeControlStatus, options: [.new], changeHandler: { (thePlayer, _) in
                if let delegate = self.delegate {
                    switch thePlayer.timeControlStatus {
                    case .playing:
                        delegate.videoPlayerDidStart(self)
                    case .paused:
                        delegate.videoPlayerDidPause(self)
                    default:
                        break
                    }
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
        guard let delegate = self.delegate else { return }
        delegate.videoPlayerDidStop(self)
        self.playerViewController?.removeFromParentViewController()
    }
    
    func play(inFullScreen fullscreen: Bool, url: URL) {
        if !self.isPlaying() {
            if !self.isShowed {
                self.show()
            }
            if fullscreen {
                // KVO para detectar cuando se pulsa el botón de cierre (X)
                self.closeObservation = self.player?.observe(\.rate, changeHandler: { [unowned self] (thePlayer, _) in
                    if thePlayer.rate == 0.0 {
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
            if self.player == nil {
                let playerItem = AVPlayerItem(url: url)
                self.player = AVPlayer(playerItem: playerItem)
                unregisterFromNotifications()
                registerForNotifications(with: playerItem)
                self.playerViewController?.player = self.player
            } else {
                self.playerViewController?.player = self.player
            }
            self.player?.play()
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
        UIView.animate(withDuration: 0.2, animations: {
            self.playerViewController?.showsPlaybackControls = false
            self.playerViewController?.player?.play()
        }, completion: { finished in
            if finished {
                self.didEnterFullScreenMode = false
                self.changeFrameObservation = nil
                self.isInFullScreen = false
            }
        })
    }
}

class VideoPlayerViewController: AVPlayerViewController {
    
    var exitFullScreenCompletion: (() -> Void)?
    
    override func viewDidLayoutSubviews() {
        UIViewController.attemptRotationToDeviceOrientation()
        super.viewDidLayoutSubviews()
        if contentOverlayView?.bounds != UIScreen.main.bounds {
            self.exitFullScreenCompletion?()
        }
    }
    
    func toFullScreen(_ completion: (() -> Void)?) {
        let selectorName: String = {
            if #available(iOS 11, *) {
                return "_transitionToFullScreenAnimated:completionHandler:"
            } else {
                return "_transitionToFullScreenViewControllerAnimated:completionHandler:"
            }
        }()
        let selector = NSSelectorFromString(selectorName)
        if self.responds(to: selector) {
            self.perform(selector, with: true, with: completion)
        }
    }
}
