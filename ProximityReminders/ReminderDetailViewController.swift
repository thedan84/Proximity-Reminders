//
//  DetailViewController.swift
//  ProximityReminders
//
//  Created by Dennis Parussini on 31-10-16.
//  Copyright © 2016 Dennis Parussini. All rights reserved.
//

import UIKit
import CoreLocation

class ReminderDetailViewController: UITableViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var locationCell: UITableViewCell!
    
    var reminder: Reminder?
    let locationManager = LocationManager()
    let coreDataManager = CoreDataManager.sharedManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let reminder = reminder, let text = reminder.text {
            self.titleLabel.text = text
            
            print(reminder)
            
            if let location = reminder.location {
                self.locationSwitch.isOn = true
                self.locationCell.isHidden = false
                locationManager.reverseLocation(location: location) { (streetAddress, houseNumber, postalCode, city, country) in
                    if let houseNumber = houseNumber {
                        self.locationCell.textLabel?.text = "\(streetAddress) \(houseNumber), \(postalCode), \(city), \(country)"
                    } else {
                        self.locationCell.textLabel?.text = "\(streetAddress), \(postalCode), \(city), \(country)"
                    }
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDetailView), name: NSNotification.Name.init("reloadDetailView"), object: nil)
    }
    
    func reloadDetailView() {
        if let reminder = self.reminder, let location = reminder.location {
            locationManager.reverseLocation(location: location) { (streetAddress, houseNumber, postalCode, city, country) in
                if let houseNumber = houseNumber {
                    self.locationCell.textLabel?.text = "\(streetAddress) \(houseNumber), \(postalCode) \(city), \(country)"
                } else {
                    self.locationCell.textLabel?.text = "\(streetAddress), \(postalCode) \(city), \(country)"
                }
            }
        }
    }

    @IBAction func locationSwitchTapped(_ sender: UISwitch) {
        if sender.isOn {
            self.locationSwitch.setOn(false, animated: true)
            self.locationCell.isHidden = true
            
            if let reminder = self.reminder {
                reminder.location = nil
                
                coreDataManager.saveContext()
            }
        } else {
            self.locationSwitch.setOn(true, animated: true)
            self.locationCell.isHidden = false
            locationManager.getPermission()
            self.locationCell.textLabel?.text = "Search location"
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSearchLocation" {
            let searchVC = segue.destination as! SearchLocationTableViewController
            if let reminder = self.reminder {
                searchVC.reminder = reminder
            }
        }
    }
}
