//
//  VideoPersister.swift
//  OCM
//
//  Created by José Estela on 19/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation
import CoreData
import GIGLibrary

protocol VideoPersister {
    
    /// Method to save the video in the persistance layer
    ///
    /// - Parameter video: The video
    func save(video: Video)
    
    /// Method to load a cached video data with the given identifier
    ///
    /// - Parameter identifier: The video identifier
    /// - Returns: The cached video data
    func loadVideo(with identifier: String) -> CachedVideoData?
}

class VideoCoreDataPersister: VideoPersister {
    
    // MARK: - Private attributes
    
    fileprivate var notification: NSObjectProtocol?
    
    fileprivate lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }()
    
    fileprivate lazy var managedObjectModel: NSManagedObjectModel? = {
        guard let modelURL = Bundle.OCMBundle().url(forResource: "VideoDB", withExtension: "momd") else { return nil }
        return NSManagedObjectModel(contentsOf: modelURL)
    }()
    
    fileprivate var managedObjectContext: NSManagedObjectContext?
    
    // MARK: - Object life cycle
    
    init() {
        self.notification = NotificationCenter.default.addObserver(forName: .UIApplicationWillTerminate, object: nil, queue: .main) { [unowned self] _ in
            self.saveContext()
        }
        self.initDataBase()
    }
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    deinit {
        if let notification = self.notification {
            NotificationCenter.default.removeObserver(notification)
        }
    }
    
    // MARK: - VideoPersister
    
    func save(video: Video) {
        self.managedObjectContext?.saveAfter {
            if let fetchedVideo = self.fetchVideo(with: video.source) {
                fetchedVideo.url = video.videoUrl
                fetchedVideo.previewUrl = video.previewUrl
                fetchedVideo.updatedAt = NSDate()
                fetchedVideo.type = video.format.rawValue
            } else if let createdVideo = self.createVideo() {
                createdVideo.identifier = video.source
                createdVideo.url = video.videoUrl
                createdVideo.previewUrl = video.previewUrl
                createdVideo.updatedAt = NSDate()
                createdVideo.type = video.format.rawValue
            }
        }
    }
    
    func loadVideo(with identifier: String) -> CachedVideoData? {
        return self.fetchVideo(with: identifier)?.toCachedVideo()
    }
}

private extension VideoCoreDataPersister {
    
    func saveContext() {
        guard let managedObjectContext = self.managedObjectContext else { logWarn("managedObjectContext is nil"); return }
        managedObjectContext.perform {
            if managedObjectContext.hasChanges {
                managedObjectContext.save()
            }
        }
    }
    
    func initDataBase() {
        guard let managedObjectModel = self.managedObjectModel else { logWarn("managedObjectModel is nil"); return }
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("VideoDB.sqlite")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch let error {
            print(error)
        }
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.managedObjectContext?.persistentStoreCoordinator = coordinator
        self.managedObjectContext?.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func createVideo() -> VideoDB? {
        return CoreDataObject<VideoDB>.create(insertingInto: self.managedObjectContext)
    }
    
    func fetchVideo(with identifier: String) -> VideoDB? {
        return CoreDataObject<VideoDB>.from(self.managedObjectContext, with: "identifier == %@", arguments: [identifier])
    }
}
