//
//  YoutubeWebInteractor.swift
//  OCM
//
//  Created by Carlos Vicente on 8/11/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation

struct YoutubeWebInteractor {
    
    // MARK: Properties

    var videoId: String?
    
    let embedHTML = "<html>" +
                        "<body style='margin:0px;padding:0px;'>" +
                            "<script type='text/javascript' src='https://www.youtube.com/iframe_api'>" +
                            "</script>" +
                                "<script type='text/javascript'>function onYouTubeIframeAPIReady()" +
                                "{" +
                                    "ytplayer=new YT.Player('playerId',{events:{onReady:onPlayerReady}})" +
                                 "}" +
                                "function onPlayerReady(a)" +
                                "{" +
                                    "a.target.playVideo();" +
                                "}" +
                                "</script><iframe id='playerId' type='text/html' width='width_placeholder' height='height_placeholder' src='https://www.youtube.com/embed/source_id_placeholder?enablejsapi=1&rel=0&playsinline=0&autoplay=1' frameborder='0' allowfullscreen>" +
                        "</body>" +
                    "</html>"
    
    func formattedEmbeddedHtml(height: Int, width: Int, videoId: String) -> String {
        
        let result = self.embedHTML.replacingOccurrences(of: "width_placeholder", with: String(width)).replacingOccurrences(of: "height_placeholder", with: String(height)).replacingOccurrences(of: "source_id_placeholder", with: videoId)
        
        return result
    }
}
