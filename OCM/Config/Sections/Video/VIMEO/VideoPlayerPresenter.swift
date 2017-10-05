//
//  VideoPlayerPresenterPresenter.swift
//  OCM
//
//  Created by José Estela on 5/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

protocol VideoPlayerUI: class {
    
}

struct VideoPlayerPresenter {
    
    // MARK: - Public attributes
    
    weak var view: VideoPlayerUI?
    let wireframe: VideoPlayerWireframe
    
    // MARK: - Input methods
    
    func viewDidLoad() {
        
    }
}
