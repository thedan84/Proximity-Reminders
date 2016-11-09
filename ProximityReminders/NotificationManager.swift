//
//  NotificationManager.swift
//  ProximityReminders
//
//  Created by Dennis Parussini on 07-11-16.
//  Copyright © 2016 Dennis Parussini. All rights reserved.
//

import Foundation
import UserNotifications
import CoreLocation

struct NotificationManager {
    let notificationCenter = UNUserNotificationCenter.current()
    
    func addLocationTrigger(forReminder reminder: Reminder, whenLeaving: Bool) -> UNLocationNotificationTrigger? {
        if let location = reminder.location {
            let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let region = CLCircularRegion(center: center, radius: 50, identifier: reminder.text!)
            switch whenLeaving {
            case true:
                region.notifyOnExit = true
                region.notifyOnEntry = false
            case false:
                region.notifyOnExit = false
                region.notifyOnEntry = true
            }
            return UNLocationNotificationTrigger(region: region, repeats: false)
        }
        return nil
    }
}