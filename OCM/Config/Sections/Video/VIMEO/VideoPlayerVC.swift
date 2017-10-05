//
//  VideoPlayerVCVC.swift
//  OCM
//
//  Created by José Estela on 5/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class VideoPlayerVC: UIViewController, VideoPlayerUI {
    
    // MARK: - Attributtes
    
    var presenter: VideoPlayerPresenter?
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.viewDidLoad()
    }
}

extension VideoPlayerVC: Instantiable {
    
    // MARK: - Instantiable
    
    static var storyboard = "Video"
    static var identifier = "VideoPlayerVC"
}
