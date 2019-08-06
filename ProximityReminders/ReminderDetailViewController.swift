//
//  DetailViewController.swift
//  ProximityReminders
//
//  Created by Dennis Parussini on 31-10-16.
//  Copyright © 2016 Dennis Parussini. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import UserNotifications

class ReminderDetailViewController: UITableViewController {
    
    //MARK: - Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var locationCell: UITableViewCell!
    @IBOutlet weak var segmentedControlCell: UITableViewCell!
    @IBOutlet weak var mapCell: UITableViewCell!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    
    var reminder: Reminder?
    let locationManager = LocationManager()
    let coreDataManager = CoreDataManager.sharedManager
    var notificationManager = NotificationManager()
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDetailView), name: NSNotification.Name.init("reloadDetailView"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let reminder = reminder, let text = reminder.text {
            self.titleLabel.text = text
            
            if let location = reminder.location {
                self.locationSwitch.isOn = true
                self.segmentedControlCell.isHidden = false
                self.locationCell.isHidden = false
                self.mapCell.isHidden = false
                self.configureLocationCell(withLocation: location)
                addRadiusOverlay(forLocation: location)
            }
        }
    }
    
    //MARK: - Helper method for NotificationCenter
    @objc func reloadDetailView() {
        if let reminder = self.reminder, let location = reminder.location {
            self.configureLocationCell(withLocation: location)
            addRadiusOverlay(forLocation: location)
            let locationTrigger = self.notificationManager.addLocationTrigger(forReminder: reminder, whenLeaving: segmentedControl.selectedSegmentIndex == 0 ? false : true)
            self.notificationManager.scheduleNewNotification(withReminder: reminder, locationTrigger: locationTrigger)
        }
    }

    //MARK: - IBActions
    @IBAction func locationSwitchTapped(_ sender: UISwitch) {
        if sender.isOn {
            self.locationSwitch.setOn(false, animated: true)
            self.locationCell.isHidden = true
            self.segmentedControlCell.isHidden = true
            self.mapCell.isHidden = true
            
            if let reminder = self.reminder {
                reminder.location = nil
                
                coreDataManager.saveContext()
            }
        } else {
            self.locationSwitch.setOn(true, animated: true)
            self.locationCell.isHidden = false
            self.segmentedControlCell.isHidden = false
            self.mapCell.isHidden = false
            self.locationCell.textLabel?.text = "Search location"
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSearchLocation" {
            let searchVC = segue.destination as! SearchLocationTableViewController
            if let reminder = self.reminder {
                searchVC.reminder = reminder
            }
        }
    }
    
    //MARK: - Cell configuration
    fileprivate func configureLocationCell(withLocation location: Location) {
        locationManager.reverseLocation(location: location) { (streetAddress, houseNumber, postalCode, city, country) in
            if let houseNumber = houseNumber {
                self.locationCell.textLabel?.text = "\(streetAddress) \(houseNumber), \(postalCode), \(city), \(country)"
            } else {
                self.locationCell.textLabel?.text = "\(streetAddress), \(postalCode), \(city), \(country)"
            }
        }
        addMapAnnotation()
    }
}

//MARK: - MKMapViewDelegate
extension ReminderDetailViewController: MKMapViewDelegate {
    //Add map annotation
    func addMapAnnotation() {
        removeMapAnnotations()
        
        let point = MKPointAnnotation()
        if let reminder = self.reminder, let location = reminder.location {
            let mapLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let coordinate = mapLocation.coordinate
            point.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            var region = MKCoordinateRegion()
            region.center = mapLocation.coordinate
            region.span.latitudeDelta = 0.01
            region.span.longitudeDelta = 0.01
            mapView.setRegion(region, animated: true)
            mapView.addAnnotation(point)
        }
    }
    
    //Remove map annotation
    func removeMapAnnotations() {
        if mapView.annotations.count != 0 {
            for annotation in mapView.annotations {
                mapView.removeAnnotation(annotation)
            }
        }
    }
    
    //Render map overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 2.0
            circleRenderer.strokeColor = .blue
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    //Display map overlay
    func addRadiusOverlay(forLocation location: Location) {
        let thisLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        mapView.addOverlay(MKCircle(center: thisLocation.coordinate, radius: 50))
    }
}
