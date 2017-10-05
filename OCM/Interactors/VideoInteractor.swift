//
//  VideoInteractor.swift
//  OCM
//
//  Created by José Estela on 5/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

struct VideoInteractor {
    
    func loadVideoInformation(for video: Video, completion: @escaping () -> Void) {
        switch video.format {
        case .youtube:
            video.previewUrl = "https://img.youtube.com/vi/\(video.source)/hqdefault.jpg"
            completion()
        default:
            break
        }
    }
}
