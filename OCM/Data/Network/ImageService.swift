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
	case Success(image: UIImage)
	case Error(error: NSError)
}


class ImageService {
	
	func fetchImage(url: String, completionHandler: ImageServiceResult -> Void) {
		let request = Request(
			method: "GET",
			baseUrl: url,
			endpoint: "",
			verbose: LogManager.shared.logLevel == .Debug
		)
		
		request.fetchImage { response in
			switch response.status {
				
			case .Success:
				do {
					let image = try response.image()
					completionHandler(.Success(image: image))
				}
				catch {
					let error = NSError.UnexpectedError("The response is not an image")
					LogError(error)
					completionHandler(.Error(error: error))
				}
				
			default:
				let error = NSError.BasicResponseErrors(response)
				LogError(error)
				completionHandler(.Error(error: error))
			}
		}
	}
	
}
