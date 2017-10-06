//
//  VimeoWrapper.swift
//  OCM
//
//  Created by eduardo parada pardo on 6/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

enum VimeoResult {
    case succes(video: Video)
    case error(error: Error)
}

protocol VimeoWrapperInput {
    func getVideo(idVideo: String)
}

protocol VimeoWrapperOutPut {
    func getVideoDidFinish(result: VimeoResult)
}

struct VimeoWrapper {
    
    let service: VimeoService
    let output: VimeoWrapperOutPut?
    
    init () {
        let accessToken = "2c13877fe3e6d0d8349482fb38fdbb88" // TODO EDU , coger esto de config
        let service = VimeoService(accessToken: accessToken)
        self.init(service: service)
    }
    
    init (service: VimeoService, output: VimeoWrapperOutPut? = nil) {
        self.service = service
        self.output = output
    }
}


// MARK: - Public method

extension VimeoWrapper: VimeoWrapperInput {
    
    func getVideo(idVideo: String) {
        self.service.getVideot(with: idVideo) { result in
            switch result {
            case .success(let video):
                print(video.videoUrl as Any)
                self.output?.getVideoDidFinish(result: .succes(video: video))
            case .error(let error):
                logWarn(error.localizedDescription)
                self.output?.getVideoDidFinish(result: .error(error: error))
            }
        }
    }
}
