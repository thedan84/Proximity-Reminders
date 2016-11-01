//
//  MasterViewController.swift
//  ProximityReminders
//
//  Created by Dennis Parussini on 31-10-16.
//  Copyright © 2016 Dennis Parussini. All rights reserved.
//

import UIKit
import CoreData

fileprivate let cellIdentifier = "reminderCell"

class ReminderTableViewController: UITableViewController {

    var detailViewController: ReminderDetailViewController? = nil
    let coreDataManager = CoreDataManager.sharedManager

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ReminderDetailViewController
        }
        
        coreDataManager.fetchedResultsController.delegate = self
        
        do {
            try coreDataManager.fetchedResultsController.performFetch()
        } catch {
            AlertManager.showAlert(withTitle: "Error while fetching data", andMessage: "\(error.localizedDescription)", inViewController: self)
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Table View
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let reminders = coreDataManager.fetchedResultsController.fetchedObjects {
            return reminders.count
        }
        
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ReminderCell
        
        let reminder = coreDataManager.fetchedResultsController.object(at: indexPath)
        cell.configure(withReminder: reminder)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

    }
    
    @IBAction func addReminderButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Reminder", message: nil, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { saveAction in
            let textField = alertController.textFields![0] as UITextField
            self.coreDataManager.saveReminder(withText: textField.text!)
        }
        saveAction.isEnabled = false
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Get milk"
            NotificationCenter.default.addObserver(forName: Notification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main, using: { (notification) in
                saveAction.isEnabled = textField.text != ""
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension ReminderTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
    }
}
