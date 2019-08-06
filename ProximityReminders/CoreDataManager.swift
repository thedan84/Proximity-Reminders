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
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return controller
    }()
        
    // MARK: - Save reminder
    
    func saveReminder(withText text: String, location: CLLocation?) {
        let reminder = Reminder(entity: Reminder.entity(), insertInto: self.managedObjectContext)
        
        reminder.text = text
        reminder.date = Date()
        
        if let location = location {
            reminder.location = self.saveLocation(location: location)
        }
        
        self.saveContext()
    }
    
    //MARK: - Helper method to save location
    fileprivate func saveLocation(location: CLLocation) -> Location {
        let locationToSave = Location(entity: Location.entity(), insertInto: self.managedObjectContext)
        
        locationToSave.latitude = location.coordinate.latitude
        locationToSave.longitude = location.coordinate.longitude
        locationToSave.identifier = String(describing: Date())
        
        return locationToSave
    }
    
    //MARK: - Delete reminder
    func deleteReminder(reminder: Reminder) {
        self.managedObjectContext.delete(reminder)
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
