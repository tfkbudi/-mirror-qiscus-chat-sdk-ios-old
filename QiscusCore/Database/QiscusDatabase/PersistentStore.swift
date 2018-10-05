//
//  PersistentStore.swift
//  QiscusDatabase
//
//  Created by Qiscus on 12/09/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import CoreData

class PresistentStore {
    // MARK: - Core Data stack
    
    private init() {
    }
    
    static var context:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        let modelURL = QiscusCore.bundle.url(forResource: "Qiscus", withExtension: "momd")!
        let container = NSPersistentContainer.init(name: "Qiscus", managedObjectModel: NSManagedObjectModel(contentsOf: modelURL)!)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    static func saveContext () {
        if context.hasChanges {
            context.perform {
                do {
                    try context.save()
                } catch {
                    fatalError("Unresolved error \(error), \(String(describing: error._userInfo))")
                }
            }
        }
    }
}
