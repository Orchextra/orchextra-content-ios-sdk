//
//  ContentListInteractor.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

enum ContentListResult {
    case success(contents: ContentList)
    case empty
    case error(message: String)
}


struct ContentListInteractor {
    
    let service: PContentListService
    let storage: Storage
    
	func contentList(from path: String, completionHandler: @escaping (ContentListResult) -> Void) {
        self.service.getContentList(with: path) { result in
            let contentListResult = self.contentListResult(fromWigetListServiceResult: result)
            completionHandler(contentListResult)
        }
    }
    
    func contentList(matchingString string: String, completionHandler: @escaping (ContentListResult) -> Void) {
        self.service.getContentList(matchingString: string) { result in
            //let contentListResult = self.contentListResult(fromWigetListServiceResult: result)
            
            ///DELETE GIGLIBRARY IMPORT!!!!
            ///REMOVE BOOL EXTENSION!!!!

            /// RANDOM SEARCH MOCK
            
            let jsonString = "{\"content\":{\"elements\":[{\"tags\":[\"ALL\",\"scan\",\"happiness\"],\"slug\":\"scan-1\",\"segmentation\":{\"requiredAuth\":\"all\"},\"elementUrl\":\"/element/scan/582c109b1b0e3df95b30be28\",\"sectionView\":{\"imageUrl\":\"https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/lisbon_demo/all/BOTON+PROMO+002.jpg\"}},{\"tags\":[\"ALL\",\"scan\",\"happiness\"],\"slug\":\"vuforia-1\",\"segmentation\":{\"requiredAuth\":\"all\"},\"elementUrl\":\"/element/vuforia/582c109b1b0e3df95b30be29\",\"sectionView\":{\"imageUrl\":\"https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/lisbon_demo/all/BOTON+PROMO+001.jpg\"}},{\"tags\":[\"ALL\",\"love\"],\"slug\":\"video-all\",\"segmentation\":{\"requiredAuth\":\"all\"},\"elementUrl\":\"/element/webview/582c109b1b0e3df95b30be2a\",\"sectionView\":{\"imageUrl\":\"https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/lisbon_demo/all/BOTON+VIDEO+WOAH.jpg\"}},{\"tags\":[\"ALL\",\"article\",\"energize\"],\"slug\":\"article-1\",\"segmentation\":{\"requiredAuth\":\"all\"},\"elementUrl\":\"/element/webview/582c109b1b0e3df95b30be2c\",\"sectionView\":{\"imageUrl\":\"https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/lisbon_demo/articles/ARTICLE+003.jpg\"}},{\"tags\":[\"ALL\",\"article\",\"love\"],\"slug\":\"article-2\",\"segmentation\":{\"requiredAuth\":\"all\"},\"elementUrl\":\"/element/webview/582c109b1b0e3df95b30be2d\",\"sectionView\":{\"imageUrl\":\"https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/lisbon_demo/articles/ARTICLE+009.jpg\"}},{\"tags\":[\"ALL\",\"article\",\"love\"],\"slug\":\"article-3\",\"segmentation\":{\"requiredAuth\":\"all\"},\"elementUrl\":\"/element/webview/582c109b1b0e3df95b30be2e\",\"sectionView\":{\"imageUrl\":\"https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/lisbon_demo/articles/ARTICLE+004.jpg\"}},{\"tags\":[\"ALL\",\"article\",\"energize\"],\"slug\":\"article-4\",\"segmentation\":{\"requiredAuth\":\"all\"},\"elementUrl\":\"/element/webview/582c109b1b0e3df95b30be2f\",\"sectionView\":{\"imageUrl\":\"https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/lisbon_demo/articles/ARTICLE+002.jpg\"}},{\"tags\":[\"ALL\",\"article\",\"light\"],\"slug\":\"article-5\",\"segmentation\":{\"requiredAuth\":\"all\"},\"elementUrl\":\"/element/webview/582c109b1b0e3df95b30be30\",\"sectionView\":{\"imageUrl\":\"https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/lisbon_demo/articles/ARTICLE+005.jpg\"}},{\"tags\":[\"ALL\",\"article\",\"light\"],\"slug\":\"article-6\",\"segmentation\":{\"requiredAuth\":\"all\"},\"elementUrl\":\"/element/webview/582c109b1b0e3df95b30be31\",\"sectionView\":{\"imageUrl\":\"https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/lisbon_demo/articles/ARTICLE+001.jpg\"}},{\"tags\":[\"ALL\",\"article\",\"happiness\"],\"slug\":\"article-7\",\"segmentation\":{\"requiredAuth\":\"all\"},\"elementUrl\":\"/element/webview/582c109b1b0e3df95b30be32\",\"sectionView\":{\"imageUrl\":\"https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/lisbon_demo/articles/ARTICLE+007.jpg\"}},{\"tags\":[\"ALL\",\"article\",\"energize\"],\"slug\":\"article-8\",\"segmentation\":{\"requiredAuth\":\"all\"},\"elementUrl\":\"/element/webview/582c109b1b0e3df95b30be33\",\"sectionView\":{\"imageUrl\":\"https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/lisbon_demo/articles/ARTICLE+006.jpg\"}},{\"tags\":[\"ALL\",\"article\",\"light\"],\"slug\":\"article-9\",\"segmentation\":{\"requiredAuth\":\"all\"},\"elementUrl\":\"/element/webview/582c109b1b0e3df95b30be34\",\"sectionView\":{\"imageUrl\":\"https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/lisbon_demo/articles/ARTICLE+008.jpg\"}}],\"tags\":[\"ALL\"],\"slug\":\"content-all\",\"type\":\"content\",\"layout\":{\"name\":\"grid1\",\"pattern\":[{\"row\":1,\"column\":1}]}},\"elementsCache\":{\"/element/webview/582c109b1b0e3df95b30be2d\":{\"preview\":{\"behaviour\":\"swipe\",\"text\":\"Love this with Felipe, Milan\",\"imageUrl\":\"https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/lisbon_demo/articles/ARTICLE+009+2.jpg\"},\"slug\":\"article-2\",\"render\":{\"url\":\"https://alwayson.orchextra.io/woahcontent2lisbon\"},\"type\":\"webview\"},\"/element/webview/582c109b1b0e3df95b30be32\":{\"preview\":{\"behaviour\":\"swipe\",\"text\":\"LOVE THIS WITH KEVIN ROME\",\"imageUrl\":\"https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/lisbon_demo/articles/ARTICLE+007+2.jpg\"},\"slug\":\"article-7\",\"render\":{\"url\":\"https://alwayson.orchextra.io/woahcontent4lisbon\"},\"type\":\"webview\"},\"/element/webview/582c109b1b0e3df95b30be2a\":{\"preview\":{},\"slug\":\"video-all\",\"render\":{\"url\":\"https://alwayson.orchextra.io/woahvideowoah\"},\"type\":\"webview\"},\"/element/webview/582c109b1b0e3df95b30be2e\":{\"preview\":{\"behaviour\":\"swipe\",\"text\":\"IN FOCUS ALESSANDRO\",\"imageUrl\":\"https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/lisbon_demo/articles/ARTICLE+004+2.jpg\"},\"slug\":\"article-3\",\"render\":{\"url\":\"https://alwayson.orchextra.io/woahcontent11lisbon\"},\"type\":\"webview\"},\"/element/vuforia/582c109b1b0e3df95b30be29\":{\"preview\":{},\"slug\":\"vuforia-1\",\"render\":{},\"type\":\"vuforia\"},\"/element/webview/582c109b1b0e3df95b30be30\":{\"preview\":{\"behaviour\":\"swipe\",\"text\":\"IN FOCUS VLADIMIR\",\"imageUrl\":\"https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/lisbon_demo/articles/ARTICLE+005+2.jpg\"},\"slug\":\"article-5\",\"render\":{\"url\":\"https://alwayson.orchextra.io/woahcontent8lisbon\"},\"type\":\"webview\"},\"/element/webview/582c109b1b0e3df95b30be33\":{\"preview\":{\"behaviour\":\"swipe\",\"text\":\"ROME\",\"imageUrl\":\"https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/lisbon_demo/articles/ARTICLE+006+2.jpg\"},\"slug\":\"article-8\",\"render\":{\"url\":\"https://alwayson.orchextra.io/woahcontent12lisbon\"},\"type\":\"webview\"},\"/element/webview/582c109b1b0e3df95b30be2f\":{\"preview\":{\"behaviour\":\"swipe\",\"text\":\"IN FOCUS MARKO\",\"imageUrl\":\"https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/lisbon_demo/articles/ARTICLE+002+2.jpg\"},\"slug\":\"article-4\",\"render\":{\"url\":\"https://alwayson.orchextra.io/woahcontent1lisbon\"},\"type\":\"webview\"},\"/element/webview/582c109b1b0e3df95b30be34\":{\"preview\":{\"behaviour\":\"swipe\",\"text\":\"WOTS THE MAGICIAN\",\"imageUrl\":\"https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/lisbon_demo/articles/ARTICLE+008+2.jpg\"},\"slug\":\"article-9\",\"render\":{\"url\":\"https://alwayson.orchextra.io/woahcontent5lisbon\"},\"type\":\"webview\"},\"/element/scan/582c109b1b0e3df95b30be28\":{\"preview\":{},\"slug\":\"scan-1\",\"render\":{},\"type\":\"scan\"},\"/element/webview/582c109b1b0e3df95b30be2c\":{\"preview\":{\"behaviour\":\"swipe\",\"text\":\"In focus with Freia, Bucharest\",\"imageUrl\":\"https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/lisbon_demo/articles/ARTICLE+003+2.jpg\"},\"slug\":\"article-1\",\"render\":{\"url\":\"https://alwayson.orchextra.io/woahcontent1lisbon\"},\"type\":\"webview\"},\"/element/webview/582c109b1b0e3df95b30be31\":{\"preview\":{\"behaviour\":\"swipe\",\"text\":\"IN THE MOMENT THE DANCER\",\"imageUrl\":\"https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/lisbon_demo/articles/ARTICLE+001+2.jpg\"},\"slug\":\"article-6\",\"render\":{\"url\":\"https://alwayson.orchextra.io/woahcontent9lisbon\"},\"type\":\"webview\"}}}"
            
            let data = jsonString.data(using: String.Encoding.utf8)!
            let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            let json = JSON(from: dictionary! as Any)
            let contentList = try? ContentList.contentList(json)
            var filteredContents = contentList?.contents.filter({ _ -> Bool in
                return Bool.random()
            })
            
            if string.lowercased() == "nothing" {
                filteredContents = []
            }
            
            let filteredContentList = ContentList(contents: filteredContents!, layout: contentList!.layout)
            completionHandler(ContentListResult.success(contents: filteredContentList))
        }
    }
    
    // MARK: - Convenience Methods
    
    func contentListResult(fromWigetListServiceResult wigetListServiceResult: WigetListServiceResult) -> ContentListResult {
        switch wigetListServiceResult {
            
        case .success(let contentList):
            if !contentList.contents.isEmpty {
                return(.success(contents: contentList))
                
            } else {
                return(.empty)
            }
            
        case .error(let error):
            return(.error(message: error.errorMessageOCM()))
        }
    }
}

fileprivate extension Bool {
    static func random() -> Bool {
        return arc4random_uniform(2) == 0
    }
}
