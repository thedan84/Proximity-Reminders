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
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func getPermission() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .authorizedWhenInUse, .denied, .restricted: locationManager.requestAlwaysAuthorization()
        default: locationManager.requestLocation()
        }
    }
    
    fileprivate func isAuthorized() -> Bool {
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
        } else {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func searchLocation(with searchString: String, completion: @escaping ([CLPlacemark]?) -> Void) {
        self.geocoder.geocodeAddressString(searchString) { (placemarks, error) in
            if let placemarksArray = placemarks {
                completion(placemarksArray)
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        if let onLocationFix = onLocationFix {
            onLocationFix(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
}
