//
//  VideoDB+CoreDataClass.swift
//  OCM
//
//  Created by José Estela on 19/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//
//

import Foundation
import CoreData

@objc(VideoDB)
public class VideoDB: NSManagedObject {
    
    func toCachedVideo() -> CachedVideoData? {
        guard let identifier = self.identifier, let url = self.url, let previewUrl = self.previewUrl, let type = self.type, let updatedAt = self.updatedAt as? Date, let format = VideoFormat.from(type) else { return nil }
        return CachedVideoData(
            video: Video(
                source: identifier,
                format: format,
                previewUrl: previewUrl,
                videoUrl: url
            ),
            updatedAt: updatedAt
        )
    }
    
}
