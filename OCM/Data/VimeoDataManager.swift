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

struct CachedVideoData {
    /// Vimeo video
    let video: Video
    /// Date where the data was retrieved
    let updatedAt: Date
}

class VimeoDataManager {
    
    // MARK: - Attributes

    let service: VimeoServiceInput
    let persister: VideoPersister
    weak var output: VimeoDataManagerOutput?
    
    // MARK: Private properties
    
    private var cachedDataQueue = DispatchQueue(label: "com.ocm.vimeoDataManager.cachedDataQueue", attributes: .concurrent)
    
    //private var vimeoDataCache = [String: CachedVimeoData]()
    
    init(service: VimeoServiceInput, persister: VideoPersister, output: VimeoDataManagerOutput? = nil) {
        self.service = service
        self.persister = persister
        self.output = output
    }
}


// MARK: - Public method

extension VimeoDataManager: VimeoDataManagerInput {
    
    func getVideo(idVideo: String) {
        if let cachedVideo = self.persister.loadVideo(with: idVideo) {
            let date = Date()
            if cachedVideo.updatedAt.addingTimeInterval(24 * 60 * 60) < date {
                // Update is it's been more than a  day after last update
                self.fetchDataForVideo(with: idVideo)
            } else {
                // Return cached video data
                self.output?.getVideoDidFinish(result: .succes(video: cachedVideo.video))
            }
        } else {
            self.fetchDataForVideo(with: idVideo)
        }
    }
}

// MARK: - Private methods

fileprivate extension VimeoDataManager {
    
    func fetchDataForVideo(with videoIdentifier: String) {
        
        self.service.getVideo(with: videoIdentifier) { result in
            switch result {
            case .success(let video):
                self.cachedDataQueue.async(flags: .barrier) {
                    self.persister.save(video: video)
                }
                self.output?.getVideoDidFinish(result: .succes(video: video))
            case .error(let error):
                logWarn(error.localizedDescription)
                self.output?.getVideoDidFinish(result: .error(error: error))
            }
        }
    }
}
