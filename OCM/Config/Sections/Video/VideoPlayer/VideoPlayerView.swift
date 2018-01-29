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
    private var playerViewController: AVPlayerViewController?
    private var player: AVPlayer?
    private var pauseObservation: NSKeyValueObservation?
    private var closeObservation: NSKeyValueObservation?
    private var changeFrameObservation: NSKeyValueObservation?
    private var isInFullScreen = false
    private var isShowed = false
    
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
        if self.isInFullScreen {
            self.playerViewController = AVPlayerViewController()
            if let playerViewController = self.playerViewController, let topViewController = self.topViewController() {
                playerViewController.view.frame = topViewController.view.bounds
                topViewController.addChildViewController(playerViewController)
                topViewController.view.addSubview(playerViewController.view)
                playerViewController.didMove(toParentViewController: topViewController)
                self.isShowed = true
            }
        } else if self.url != nil {
            let videoPlayerContainerView = UIView(frame: self.frame)
            let playerLayer = AVPlayerLayer(player: self.player)
            playerLayer.frame = self.frame
            videoPlayerContainerView.layer.addSublayer(playerLayer)
            playerLayer.videoGravity = .resizeAspectFill
            self.addSubviewWithAutolayout(videoPlayerContainerView)
            self.isShowed = true
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
            self.playerViewController = AVPlayerViewController()
            UIView.animate(withDuration: 0.2, animations: {
                if let playerViewController = self.playerViewController {
                    playerViewController.showsPlaybackControls = false
                    playerViewController.player = self.player
                    playerViewController.view.frame = self.bounds
                    self.addSubviewWithAutolayout(playerViewController.view)
                }
            }, completion: { finished in
                if finished {
                    self.playerViewController?.showsPlaybackControls = true
                    self.playerViewController?.goToFullScreen()
                    self.changeFrameObservation = self.playerViewController?.observe(\.view.frame, options: [.new]) { (playerViewController, _) in
                        print(playerViewController)
                    }
                    if let changeFrameObservation = self.changeFrameObservation {
                        self.observers.append(changeFrameObservation)
                    }
                }
            })
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
        if fullscreen {
            if !self.isShowed {
                self.show()
            }
            let playerItem = AVPlayerItem(url: url)
            let player = AVPlayer(playerItem: playerItem)
            unregisterFromNotifications()
            registerForNotifications(with: playerItem)
            self.playerViewController?.player = player
            // KVO para detectar cuando se pulsa el botón de cierre (X)
            self.closeObservation = player.observe(\.rate, changeHandler: { [unowned self] (thePlayer, _) in
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
        } else if !self.isShowed {
            self.player = AVPlayer(url: url)
            self.show()
        }
        self.player?.play()
        self.videoDidStart()
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
}

extension AVPlayerViewController {
    
    func goToFullScreen() {
        let selector = NSSelectorFromString("_transitionToFullScreenViewControllerAnimated:completionHandler:")
        if self.responds(to: selector) {
            self.perform(selector, with: true, with: nil)
        }
    }
}
