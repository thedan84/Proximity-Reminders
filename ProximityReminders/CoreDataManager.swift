//
//  CoreDataManager.swift
//  ProximityReminders
//
//  Created by Dennis Parussini on 31-10-16.
//  Copyright © 2016 Dennis Parussini. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

class CoreDataManager {
    
    static let sharedManager = CoreDataManager()
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ProximityReminders")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Reminder> = {
        let fetchRequest: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return controller
    }()
    
    lazy var reminderEntityDescription: NSEntityDescription = {
        return NSEntityDescription.entity(forEntityName: "Reminder", in: self.managedObjectContext)!
    }()
    
    lazy var locationEntityDescriptopn: NSEntityDescription = {
        return NSEntityDescription.entity(forEntityName: "Location", in: self.managedObjectContext)!
    }()
    
    // MARK: - Core Data Saving support
    
    func saveReminder(withText text: String, andLocation location: CLLocation? = nil) {
        let reminder = Reminder(entity: self.reminderEntityDescription, insertInto: self.managedObjectContext)
        
        reminder.text = text
        
        if let reminderLocation = location {
            let location = Location(entity: locationEntityDescriptopn, insertInto: self.managedObjectContext)
            
            location.latitude = reminderLocation.coordinate.latitude
            location.longitude = reminderLocation.coordinate.longitude
        }
        
        self.saveContext()
    }
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
