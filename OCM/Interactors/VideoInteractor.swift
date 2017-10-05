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
        case .vimeo:
            // TODO: Remove this mock data
            video.previewUrl = "https://i.vimeocdn.com/video/645686670_640x360.jpg?r=pad"
            video.videoUrl = "https://player.vimeo.com/play/794378324?s=226156564_1507246990_6890abd4c0ca83b51d6cb95264fb5dc9&loc=external&context=Vimeo%5CController%5CApi%5CResources%5CVideoController.&download=1&filename=Karin%2BDragos%2Btr%25C3%25BCkk%25C3%25B6s%2Bt%25C3%25BCkr%25C3%25B6s%2Bkalandjai%2Ba%2BBalaton%2BSoundon165.mp4"
            completion()
        }
    }
}
