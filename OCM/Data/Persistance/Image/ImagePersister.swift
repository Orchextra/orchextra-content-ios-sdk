//
//  ImagePersister.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 20/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

import Foundation
import CoreData
import GIGLibrary

protocol ImagePersister {
    
    /// Method to save information about a cached image in the database (if it does not exist
    ///  already), otherwise it updates it's dependencies !!!
    ///
    /// - Parameter cachedImage: `CachedImage` with the data for the stored image.
    func save(cachedImage: CachedImage)
    
    func loadCachedImages() -> [CachedImage]
    
    func removeCachedImages()
    
    func removeCachedImages(with imagePath: String)

}

class ImageCoreDataPersister: ImagePersister {
    
    // MARK: - Public attributes
    
    static let shared = ImageCoreDataPersister()
    
    // MARK: - Private attributes
    
    fileprivate var notification: NSObjectProtocol?
    
    fileprivate lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }()
    
    fileprivate lazy var managedObjectModel: NSManagedObjectModel? = {
        guard let modelURL = Bundle.OCMBundle().url(forResource: "ImageDB", withExtension: "momd") else { return nil }
        return NSManagedObjectModel(contentsOf: modelURL)
    }()
    
    fileprivate var managedObjectContext: NSManagedObjectContext?
    
    // MARK: - Life cycle
    
    init() {
        self.notification = NotificationCenter.default.addObserver(forName: .UIApplicationWillTerminate, object: nil, queue: .main) { [unowned self] _ in
            self.saveContext()
        }
        self.initDataBase()
    }
    
    deinit {
        if let notification = self.notification {
            NotificationCenter.default.removeObserver(notification)
        }
    }
    
    // MARK: - Save methods
    
    func save(cachedImage: CachedImage) {
        
        guard cachedImage.location != nil else { return }
        
        let dependencies = cachedImage.dependencies.flatMap { (identifier) -> ImageDependencyDB? in
            return self.fetchImageDependency(with: identifier) ?? self.createImageDependency(with: identifier)
        }
        
        if let storedImage = self.fetchCachedImage(with: cachedImage.imagePath) {
            // Update dependencies
            if let storedDependencies = storedImage.dependencies {
                storedImage.removeFromDependencies(storedDependencies)
            }
            storedImage.addToDependencies(NSSet(array: dependencies))
        } else {
            if let cachedImageDB = createCachedImage() {
                cachedImageDB.imagePath = cachedImage.imagePath
                cachedImageDB.diskLocation = cachedImage.location?.absoluteString
                cachedImageDB.addToDependencies(NSSet(array: dependencies))
            }
        }
        self.saveContext()
    }
    
    // MARK: - Load methods
    
    func loadCachedImages() -> [CachedImage] {
    
        let cachedImages = self.fetchCachedImages().flatMap { (storedImage) -> CachedImage? in
            
            guard let storedImage = storedImage else { return nil }
            return self.mapToCachedImage(storedImage)
        }
        return cachedImages

    }
    
    // MARK: - Delete methods
    
    func removeCachedImages() {
    
        // TODO: Implement for garbage collection or clean up
    }
    
    func removeCachedImages(with imagePath: String) {
        
        // TODO: Implement for garbage collection or clean up
    }
}

private extension ImageCoreDataPersister {
    
    // MARK: - DataBase helpers
    
    func createCachedImage() -> CachedImageDB? {
        return CoreDataObject<CachedImageDB>.create(insertingInto: self.managedObjectContext)
    }
    
    func fetchCachedImage(with imagePath: String) -> CachedImageDB? {
        return CoreDataObject<CachedImageDB>.from(self.managedObjectContext, with: "imagePath == %@", imagePath)
    }
    
    func fetchCachedImages() -> [CachedImageDB?] {
        return CoreDataArray<CachedImageDB>.from(self.managedObjectContext) ?? []
    }
    
    func createImageDependency(with identifier: String) -> ImageDependencyDB? {
        let result = CoreDataObject<ImageDependencyDB>.create(insertingInto: self.managedObjectContext)
        result?.identifier = identifier
        return result
    }
    
    func fetchImageDependency(with identifier: String) -> ImageDependencyDB? {
        return CoreDataObject<ImageDependencyDB>.from(self.managedObjectContext, with: "identifier == %@", identifier)
    }
    
    // MARK: - Map model helpers
    
    func mapToCachedImage(_ cachedImageDB: CachedImageDB) -> CachedImage? {
        
        guard
            let imagePath = cachedImageDB.imagePath,
            let location = cachedImageDB.diskLocation,
            let imageDependencies = cachedImageDB.dependencies
        else {
            return nil
        }
        
        var dependencies: [String] = []
        for dependency in imageDependencies {
            if let castedDependency = dependency as? ImageDependencyDB, let identifier = castedDependency.identifier {
                dependencies.append(identifier)
            }
        }
        
        return CachedImage(imagePath: imagePath, location: URL(fileURLWithPath: location), dependencies: dependencies)
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        guard let managedObjectContext = self.managedObjectContext else { return }
        if managedObjectContext.hasChanges {
            DispatchQueue.main.async {
                managedObjectContext.save()
            }
        }
    }
    
    func initDataBase() {
        
        guard let managedObjectModel = self.managedObjectModel else { return }
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("ImageDB.sqlite")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch let error {
            print(error)
        }
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.managedObjectContext?.persistentStoreCoordinator = coordinator
        self.managedObjectContext?.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

}
