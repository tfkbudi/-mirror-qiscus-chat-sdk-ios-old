//
//  PersistentStore.swift
//  QiscusDatabase
//
//  Created by Qiscus on 12/09/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import CoreData

class PresistentStore {
    // MARK: Core Data stack
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
                QiscusLogger.errorPrint("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: Core Data Saving support
    static func saveContext () {
        // persistentContainer.performBackgroundTask { (_context) in
            context.perform {
                do {
                    if context.hasChanges {
                        try context.save()
                    }else {
                        // QiscusLogger.debugPrint("no changes db")
                    }
                } catch {
                    let saveError = error as NSError
                    QiscusLogger.errorPrint("Unable to Save Changes of Managed Object Context")
                    QiscusLogger.errorPrint("\(saveError), \(saveError.localizedDescription)")
                }
            }
        // }
    }
    
    static func clear() {
        do {
            try persistentContainer.persistentStoreCoordinator.managedObjectModel.entities.forEach({ (entity) in
                if let name = entity.name {
                    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: name)
                    let request = NSBatchDeleteRequest(fetchRequest: fetch)
                    try context.execute(request)
                }
            })
            try context.save()
        } catch {
            let saveError = error as NSError
            QiscusLogger.errorPrint("Unable to clear DB")
            QiscusLogger.errorPrint("\(saveError), \(saveError.localizedDescription)")
        }
    }
}
