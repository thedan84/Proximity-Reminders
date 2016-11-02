//
//  SearchLocationTableViewController.swift
//  ProximityReminders
//
//  Created by Dennis Parussini on 02-11-16.
//  Copyright © 2016 Dennis Parussini. All rights reserved.
//

import UIKit
import CoreLocation

fileprivate let cellIdentifier = "searchCell"

class SearchLocationTableViewController: UITableViewController, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    var placemarks: [CLPlacemark]?
    let locationManager = LocationManager()
    let geocoder = CLGeocoder()
    
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
        self.definesPresentationContext = true
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let placemarks = self.placemarks else { return 0 }
        return placemarks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        if let placemark = placemarks?[indexPath.row] {
            if let streetAddress = placemark.thoroughfare, let postalCode = placemark.postalCode, let city = placemark.locality, let country = placemark.country {
                if let number = placemark.subThoroughfare {
                    cell.textLabel?.text = "\(streetAddress) \(number), \(postalCode) \(city), \(country)"
                } else {
                    cell.textLabel?.text = "\(streetAddress), \(postalCode) \(city), \(country)"
                }
                
            }
        }
        
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        self.filterAddress(forSearchString: text)
    }
    
    fileprivate func filterAddress(forSearchString searchString: String) {
        locationManager.searchLocation(with: searchString, completion: { (placemarks) in
            if let placemarksArray = placemarks {
                self.placemarks = placemarksArray
                self.tableView.reloadData()
            }
        })
    }
}
