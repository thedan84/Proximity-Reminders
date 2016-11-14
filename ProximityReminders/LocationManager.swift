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
    
    //MARK: - Properties
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    var onLocationFix: ((CLLocation) -> Void)?
    let coreDataManager = CoreDataManager.sharedManager
    
    //MARK: - Initialization
    override init() {
        super.init()
        
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    //MARK: - Search location
    func searchLocation(with searchString: String, completion: @escaping ([CLPlacemark]?) -> Void) {
        self.geocoder.geocodeAddressString(searchString) { (placemarks, error) in
            if let placemarksArray = placemarks {
                OperationQueue.main.addOperation {
                    completion(placemarksArray)
                }
            }
        }
    }
    
    //MARK: - Reverse location
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
}
