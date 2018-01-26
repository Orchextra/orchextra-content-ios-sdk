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
    func videoPlayerDidStart(_ videoPlayer: VideoPlayer)
    func videoPlayerDidStop(_ videoPlayer: VideoPlayer)
    func videoPlayerDidPause(_ videoPlayer: VideoPlayer)
}

class VideoPlayer: UIView {
    
    // MARK: - Public attributes
    
    weak var delegate: VideoPlayerDelegate?
    var observers =  [NSObjectProtocol]()
    lazy var notificationsQueue: OperationQueue = {
        return OperationQueue()
    }()
    
    // MARK: - Private attributes
    
    private var playerViewController: AVPlayerViewController?
    private var player: AVPlayer?
    private weak var containerViewController: UIViewController?
    private weak var containerView: UIView?
    var url: URL?
    private var pauseObservation: NSKeyValueObservation?
    private var closeObservation: NSKeyValueObservation?
    
    // MARK: - Public methods
    
    init(showingIn viewController: UIViewController, with frame: CGRect) {
        self.containerViewController = viewController
        super.init(frame: frame)
    }
    
    init(showingIn view: UIView) {
        self.containerView = view
        super.init(frame: view.frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        unregisterFromNotifications()
    }
    
    func showPlayer() {
        if let containerViewController = self.containerViewController {
            self.playerViewController = AVPlayerViewController()
            if let playerViewController = self.playerViewController {
                playerViewController.view.frame = self.bounds
                containerViewController.addChildViewController(playerViewController)
                containerViewController.view.addSubview(playerViewController.view)
                playerViewController.didMove(toParentViewController: containerViewController)
            }
        }
    }
    
    func play() {
        guard let url = self.url else { return logWarn("There is an error loading the url of the video") }
        if self.player == nil {
            if let containerViewController = self.containerViewController {
                if self.playerViewController == nil {
                    self.showPlayer()
                }
                self.player = self.playInViewController(containerViewController, with: url)
            } else if let containerView = self.containerView {
                self.player = self.playInView(containerView, with: url)
            }
            
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
        self.player?.play()
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
    
    private func playInViewController(_ containerViewController: UIViewController, with url: URL) -> AVPlayer {
        let playerItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: playerItem)
        unregisterFromNotifications()
        registerForNotifications(with: playerItem)
        self.playerViewController?.player = player
        // KVO para detectar cuando se pulsa el botón de cierre (X)
        self.closeObservation = player.observe(\.rate, changeHandler: { [unowned self] (thePlayer, _) in
            if thePlayer.rate == 0.0, containerViewController.isBeingDismissed {
                // Con esta condición se comprueba si la reproducción del item no ha finalizado (usuario cierra la ventana sin esperar el final del video)
                // Si se quita se producen dos eventos stop ya que el evento de video finalizado se gestiona en la notificación AVPlayerItemDidPlayToEndTime
                if let playerItem = thePlayer.currentItem, playerItem.duration > thePlayer.currentTime() {
                    DispatchQueue.main.async {
                        self.notifyVideoStop()
                    }
                }
            }
        })
        return player
    }
    
    private func playInView(_ containerView: UIView, with url: URL) -> AVPlayer {
        let player = AVPlayer(url: url)
        let videoPlayerContainerView = UIView(frame: containerView.frame)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = containerView.frame
        videoPlayerContainerView.layer.addSublayer(playerLayer)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        containerView.addSubviewWithAutolayout(videoPlayerContainerView)
        return player
    }
    
    private func registerForNotifications(with playerItem: AVPlayerItem) {
        
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
    
    private func notifyVideoStop() {
        guard let delegate = self.delegate else { return }
        delegate.videoPlayerDidStop(self)
        self.playerViewController?.removeFromParentViewController()
    }
    
    private func unregisterFromNotifications() {
        for observer in self.observers {
            NotificationCenter.default.removeObserver(observer)
        }
        self.observers.removeAll()
    }
}
