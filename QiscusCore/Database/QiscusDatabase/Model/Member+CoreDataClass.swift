//
//  Member+CoreDataClass.swift
//  QiscusDatabase
//
//  Created by Qiscus on 12/09/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//
//

import Foundation
import CoreData

 class Member: NSManagedObject {

}

extension Member {
    // create behaviour like active record
     static func all() -> [Member] {
        let fetchRequest:NSFetchRequest<Member> = Member.fetchRequest()
        var results = [Member]()
        
        do {
            results = try  QiscusDatabase.context.fetch(fetchRequest)
        } catch  {
            
        }
        return results
    }
    
     static func generate() -> Member {
        return Member(context: QiscusDatabase.context)
    }
    
     static func find(predicate: NSPredicate) -> [Member]? {
        let fetchRequest:NSFetchRequest<Member> = Member.fetchRequest()
        fetchRequest.predicate = predicate
        do {
            return try  QiscusDatabase.context.fetch(fetchRequest)
        } catch  {
            return nil
        }
    }
    
    /// Clear all member data
     static func clear() {
        let fetchRequest:NSFetchRequest<Member> = Member.fetchRequest()
        let delete = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        do {
            try  QiscusDatabase.context.execute(delete)
        } catch  {
            // failed to clear data
        }
    }
    
    // non static
     func remove() {
        QiscusDatabase.context.delete(self)
        self.save()
    }
    
     func update() {
        self.save()
    }
    
     func save() {
        QiscusDatabase.save()
    }
}
