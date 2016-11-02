//
//  SearchLocationTableViewController.swift
//  ProximityReminders
//
//  Created by Dennis Parussini on 02-11-16.
//  Copyright © 2016 Dennis Parussini. All rights reserved.
//

import UIKit

class SearchLocationTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        return cell
    }
}
