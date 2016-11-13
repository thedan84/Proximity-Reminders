//
//  LocationManager.swift
//  ProximityReminders
//
//  Created by Dennis Parussini on 31-10-16.
//  Copyright © 2016 Dennis Parussini. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    var onLocationFix: ((CLLocation) -> Void)?
    let coreDataManager = CoreDataManager.sharedManager
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func isAuthorized() -> Bool {
        var isAuthorized = false
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .denied, .restricted, .authorizedWhenInUse: isAuthorized = false
        case .authorizedAlways: isAuthorized = true
        }
        
        return isAuthorized
    }
    
    func getLocation() {
        if self.isAuthorized() {
            locationManager.requestLocation()
        }
    }
    
    func searchLocation(with searchString: String, completion: @escaping ([CLPlacemark]?) -> Void) {
        self.geocoder.geocodeAddressString(searchString) { (placemarks, error) in
            if let placemarksArray = placemarks {
                OperationQueue.main.addOperation {
                    completion(placemarksArray)
                }
            }
        }
    }
    
    func reverseLocation(location: Location, completion: @escaping (_ streetAddress: String, _ houseNumber: String?, _ postalCode: String, _ city: String, _ country: String) -> Void) {
        let locationToReverse = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        self.geocoder.reverseGeocodeLocation(locationToReverse) { placemarks, error in
            if let placemark = placemarks?.first {
                guard let streedAddress = placemark.thoroughfare, let postalCode = placemark.postalCode, let city = placemark.locality, let country = placemark.country else { return }
                
                let houseNumber = placemark.subThoroughfare
                
                completion(streedAddress, houseNumber, postalCode, city, country)
            }
        }
    }
    
    func reminderText(forRegionIdentifier regionIdentifer: String) -> String? {
        let locations = coreDataManager.loadAllLocations()
        
        for location in locations {
            for region in CLLocationManager().monitoredRegions {
                guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == location.identifier, let reminders = location.reminders else { continue }
                for reminder in reminders {
                    if let text = (reminder as! Reminder).text {
                        return text
                    }
                }
            }
            
        }
        return nil
    }
    
    func startMonitoring(location: Location) {
        let thisLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let region = CLCircularRegion(center: thisLocation.coordinate, radius: 50, identifier: location.identifier!)
        self.locationManager.startMonitoring(for: region)
    }
    
    func stopMonitoring(location: Location) {
        for region in CLLocationManager().monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == location.identifier else { continue }
            self.locationManager.stopMonitoring(for: circularRegion)
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        if let onLocationFix = onLocationFix {
            onLocationFix(location)
        }
    }
}
