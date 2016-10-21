//
//  ImageDownloader.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 20/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary


struct ImageDownloader {
	
	static let shared = ImageDownloader()
	static var queue: [UIImageView: Request] = [:]
	static var stack: [UIImageView] = []
	static var images: [String: UIImage] = [:]
	
	
	func download(url: String, for view: UIImageView) {
		if let request = ImageDownloader.queue[view] {
			ImageDownloader.queue.removeValue(forKey: view)
			request.cancel()
		}
		
		if let image = ImageDownloader.images[url] {
			view.image = image
		} else {
			self.loadImage(url: url, in: view)
		}
	}
	
	private func loadImage(url: String, in view: UIImageView) {
		let request = Request(method: "GET", baseUrl: url, endpoint: "")
		ImageDownloader.queue[view] = request
		ImageDownloader.stack.append(view)
		
		if ImageDownloader.stack.count == 1 {
			self.downloadNext()
		}
	}
	
	private func downloadNext() {
		guard let view = ImageDownloader.stack.popLast() else { return }
		guard let request = ImageDownloader.queue[view] else { return }
		
		request.fetch { response in
			
			switch response.status {
			case .success:
				DispatchQueue(label: "com.gigigo.imagedownloader", qos: .background).async {
					if let image = try? response.image() {
						let width = view.width() * UIScreen.main.scale
						let height = view.height() * UIScreen.main.scale
						let resized = image.imageProportionally(with: CGSize(width: width, height: height))
						ImageDownloader.images[request.baseURL] = resized
						
						DispatchQueue.main.sync {
							view.image = resized
						}
					}
				}
				
			default:
				LogError(response.error)
			}
			self.downloadNext()
		}
	}
	
}
