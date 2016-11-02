//
//  DetailViewController.swift
//  ProximityReminders
//
//  Created by Dennis Parussini on 31-10-16.
//  Copyright © 2016 Dennis Parussini. All rights reserved.
//

import UIKit

class ReminderDetailViewController: UITableViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var locationCell: UITableViewCell!
    
    var reminder: Reminder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if reminder?.location != nil {
            self.locationSwitch.isOn = true
            self.locationCell.isHidden = false
        }
    }

    @IBAction func locationSwitchTapped(_ sender: UISwitch) {
        if sender.isOn {
            self.locationSwitch.setOn(false, animated: true)
            self.locationCell.isHidden = true
        } else {
            self.locationSwitch.setOn(true, animated: true)
            self.locationCell.isHidden = false
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        
    }
    
}

