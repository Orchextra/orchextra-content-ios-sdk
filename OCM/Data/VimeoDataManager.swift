//
//  VimeoDataManager.swift
//  OCM
//
//  Created by Eduardo Parada Pardo on 6/10/17.
//  Updated by Jerilyn Goncalves on 02/02/2018.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

enum VimeoResult {
    case succes(video: Video)
    case error(error: Error)
}

protocol VimeoDataManagerInput {
    weak var output: VimeoDataManagerOutput? { get set }
    func getVideo(idVideo: String)
}

protocol VimeoDataManagerOutput: class {
    func getVideoDidFinish(result: VimeoResult)
}

struct CachedVimeoData {
    /// Vimeo video
    let video: Video
    /// Date where the data was retrieved
    let updatedAt: Date
}

class VimeoDataManager {
    
    let service: VimeoServiceInput
    weak var output: VimeoDataManagerOutput?
    
    private var vimeoDataCache: [CachedVimeoData]?
    
    init(service: VimeoServiceInput, output: VimeoDataManagerOutput? = nil) {
        self.service = service
        self.output = output
    }
}


// MARK: - Public method

extension VimeoDataManager: VimeoDataManagerInput {
    
    func getVideo(idVideo: String) {
        if let cachedVideo = self.cachedDataForVideo(with: idVideo) {
            // TODO: Check updatedAt !!!
            self.output?.getVideoDidFinish(result: .succes(video: cachedVideo.video))
        } else {
            self.fetchDataForVideo(with: idVideo)
        }

    }
}

// MARK: - Private methods

fileprivate extension VimeoDataManager {
    
    func cachedDataForVideo(with videoIdentifier: String) -> CachedVimeoData? {
        
        let cachedData = self.vimeoDataCache?.first(where: { (data) -> Bool in
            return data.video.source == videoIdentifier
        })
        return cachedData
    }
    
    func fetchDataForVideo(with videoIdentifier: String) {
        
        self.service.getVideo(with: videoIdentifier) { result in
            switch result {
            case .success(let video):
                // TODO: Store data on cache !!!
                self.output?.getVideoDidFinish(result: .succes(video: video))
            case .error(let error):
                logWarn(error.localizedDescription)
                self.output?.getVideoDidFinish(result: .error(error: error))
            }
        }
    }
}
