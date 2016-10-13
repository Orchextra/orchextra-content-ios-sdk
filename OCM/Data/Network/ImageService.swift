//
//  ImageService.swift
//  OCM
//
//  Created by Alejandro Jiménez on 5/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


enum ImageServiceResult {
	case success(image: UIImage)
	case error(error: NSError)
}


class ImageService {
	
	func fetchImage(_ url: String, completionHandler: @escaping (ImageServiceResult) -> Void) {
		let request = Request(
			method: "GET",
			baseUrl: url,
			endpoint: "",
			verbose: LogManager.shared.logLevel == .debug
		)
		
		request.fetchImage { response in
			switch response.status {
				
			case .success:
				do {
					let image = try response.image()
					completionHandler(.success(image: image))
					
				} catch {
					let error = NSError.UnexpectedError("The response is not an image")
					LogError(error)
					completionHandler(.error(error: error))
				}
				
			default:
				let error = NSError.BasicResponseErrors(response)
				LogError(error)
				completionHandler(.error(error: error))
			}
		}
	}
	
}
