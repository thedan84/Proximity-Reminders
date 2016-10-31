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
    let locationManager = LocationManager()
    
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
        
    // MARK: - Core Data Saving support
    
    func saveReminder(withText text: String, locationEnabled: Bool = false) {
        let reminder = Reminder(context: self.managedObjectContext)
        
        reminder.text = text
        reminder.date = NSDate()

        if locationEnabled {
            let location = self.saveLocation()
            reminder.location = location
        }
        
        self.saveContext()
    }
    
    fileprivate func saveLocation() -> Location {
        let locationToSave = Location(context: self.managedObjectContext)
        
        locationManager.getLocation()
        locationManager.onLocationFix = { location in
            locationToSave.longitude = location.coordinate.longitude
            locationToSave.latitude = location.coordinate.latitude
        }
        
        return locationToSave
    }
    
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
