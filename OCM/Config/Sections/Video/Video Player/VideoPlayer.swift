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
    private weak var containerViewController: UIViewController?
    private var pauseObservation: NSKeyValueObservation?
    private var closeObservation: NSKeyValueObservation?
    
    // MARK: - Public methods
    
    init(showingIn viewController: UIViewController, with frame: CGRect) {
        self.containerViewController = viewController
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        unregisterFromNotifications()
    }
    
    func showPlayer() {
        self.playerViewController = AVPlayerViewController()
        if let playerViewController = self.playerViewController {
            playerViewController.view.frame = self.bounds
            self.containerViewController?.addChildViewController(playerViewController)
            self.containerViewController?.view.addSubview(playerViewController.view)
            playerViewController.didMove(toParentViewController: self.containerViewController)
        }
    }
    
    func play(with url: URL) {
        if self.playerViewController == nil {
            self.showPlayer()
        }
        let playerItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: playerItem)
        unregisterFromNotifications()
        registerForNotifications(with: playerItem)
        self.playerViewController?.player = player

        //KVO para detectar cuando se pulsa el botón de cierre (X)
        self.closeObservation = player.observe(\.rate, changeHandler: { [unowned self] (thePlayer, _) in
            if let containerViewController = self.containerViewController, thePlayer.rate == 0.0, containerViewController.isBeingDismissed {
                //Con esta condición se comprueba si la reproducción del item no ha finalizado (usuario cierra la ventana sin esperar el final del video)
                //Si se quita se producen dos eventos stop ya que el evento de video finalizado se gestiona en la notificación AVPlayerItemDidPlayToEndTime
                if let playerItem = thePlayer.currentItem, playerItem.duration > thePlayer.currentTime() {
                    DispatchQueue.main.async {
                        self.notifyVideoStop()
                    }
                }
            }
        })
        
        if #available(iOS 10.0, *) {
            //KVO para detectar cuando cambia el estado de la reproducción (start / pause)
            self.pauseObservation = player.observe(\.timeControlStatus, options: [.new], changeHandler: { (thePlayer, _) in
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
            guard let delegate = self.delegate else { return }
            delegate.videoPlayerDidStart(self)
        }
        
        player.play()
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
    
    private func notifyVideoStop() {
        guard let delegate = self.delegate else { return }
        delegate.videoPlayerDidStop(self)
        self.playerViewController?.removeFromParentViewController()
    }
    
    func unregisterFromNotifications() {
        for observer in self.observers {
            NotificationCenter.default.removeObserver(observer)
        }
        self.observers.removeAll()
    }
}
