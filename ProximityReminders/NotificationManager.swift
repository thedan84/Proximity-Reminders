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
    
    //MARK: - Properties
    let notificationCenter = UNUserNotificationCenter.current()
    
    //MARK: - Add location trigger
    func addLocationTrigger(forReminder reminder: Reminder, whenLeaving: Bool) -> UNLocationNotificationTrigger? {
        if let location = reminder.location, let identifier = location.identifier {
            let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let region = CLCircularRegion(center: center, radius: 50, identifier: identifier)
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

    //MARK: - Schedule notification
    func scheduleNewNotification(withReminder reminder: Reminder, locationTrigger trigger: UNLocationNotificationTrigger?) {
        if let text = reminder.text, let location = reminder.location, let identifier = location.identifier, let notificationTrigger = trigger {
            let content = UNMutableNotificationContent()
            content.body = text
            content.sound = UNNotificationSound.default
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: notificationTrigger)
            notificationCenter.add(request)
        }
    }
}
