//
//  CoreDataManager.swift
//  Contraction-ator
//
//  Created by Greg Weiss on 3/13/18.
//  Copyright © 2018 Greg Weiss. All rights reserved.
//

import UIKit
import CoreData

public class CoreDataManager: NSObject {
    
    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate 
        return appDelegate.persistentContainer.viewContext
    }
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let container = self.persistentContainer
        return container.viewContext
    }()

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Contraction_ator")
        container.loadPersistentStores() { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error: \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
}

extension NSManagedObjectContext {
    func saveChanges() {
        if self.hasChanges {
            do {
                try save()
            } catch {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    
}
