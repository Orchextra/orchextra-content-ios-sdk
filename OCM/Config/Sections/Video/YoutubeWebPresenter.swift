//
//  YoutubeWebPresenter.swift
//  OCM
//
//  Created by Carlos Vicente on 8/11/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation

protocol YoutubeWebViewPresenterProtocol {
    func viewIsReady(with height: Int, width: Int)
}

protocol YoutubeWebView: class {
    func load(with htmlString: String)
}

struct YoutubeWebPresenter: YoutubeWebViewPresenterProtocol {
    
    weak var view: YoutubeWebView?
    let interactor: YoutubeWebInteractor
    
    // MARK: Presenter protocol
    
    func viewIsReady(with height: Int, width: Int) {
        
        guard let videoId = self.interactor.videoId else {
            logWarn("Invalid video id")
            return
        }
        
        let htmlString = self.interactor.formattedEmbeddedHtml(
            height: height,
            width: width,
            videoId: videoId
        )
        
        self.view?.load(with: htmlString)
    }
}
