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
            
            if reminder.location != nil {
                self.locationSwitch.isOn = true
                self.locationCell.isHidden = false
            }
        }
    }

    @IBAction func locationSwitchTapped(_ sender: UISwitch) {
        if sender.isOn {
            self.locationSwitch.setOn(false, animated: true)
            self.locationCell.isHidden = true
        } else {
            self.locationSwitch.setOn(true, animated: true)
            self.locationCell.isHidden = false
            locationManager.getPermission()
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        
    }
}
