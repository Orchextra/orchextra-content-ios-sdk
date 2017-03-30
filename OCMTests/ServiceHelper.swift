//
//  HTTPHelper.swift
//  OCM
//
//  Created by José Estela on 8/2/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import OHHTTPStubs

class ServiceHelper {
    
    class func mockResponse(for urlPath: String, with jsonFile: String) {
        _ = stub(condition: isPath(urlPath), response: { _ in
            return ServiceHelper.stubResponse(with: jsonFile)
        })
    }
    
    private class func stubResponse(with json: String) -> OHHTTPStubsResponse {
        return OHHTTPStubsResponse(
            fileAtPath: OHPathForFile(json, ServiceHelper.self)!,
            statusCode: 200,
            headers: ["Content-Type": "application/json"]
        )
    }
}
