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
    weak var output: VimeoWrapperOutput? { get set }
    func getVideo(idVideo: String)
}

protocol VimeoWrapperOutput: class {
    func getVideoDidFinish(result: VimeoResult)
}

class VimeoWrapper {
    
    let service: VimeoServiceInput
    weak var output: VimeoWrapperOutput?
    
    convenience init() {
        let accessToken = "2c13877fe3e6d0d8349482fb38fdbb88" // TODO EDU , coger esto de config
        let service = VimeoService(accessToken: accessToken)
        self.init(service: service)
    }
    
    init(service: VimeoServiceInput, output: VimeoWrapperOutput? = nil) {
        self.service = service
        self.output = output
    }
}


// MARK: - Public method

extension VimeoWrapper: VimeoWrapperInput {
    
    func getVideo(idVideo: String) {
        self.service.getVideo(with: idVideo) { result in
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
