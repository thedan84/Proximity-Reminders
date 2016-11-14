//
//  ReminderCell.swift
//  ProximityReminders
//
//  Created by Dennis Parussini on 31-10-16.
//  Copyright © 2016 Dennis Parussini. All rights reserved.
//

import UIKit

class ReminderCell: UITableViewCell {
        
    //MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - Cell configuration
    func configure(withReminder reminder: Reminder) {
        self.textLabel?.text = reminder.text
        if reminder.isCompleted {
            self.accessoryType = .checkmark
        } else {
            self.accessoryType = .none
        }
    }
}
