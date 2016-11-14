//
//  AlertManager.swift
//  ProximityReminders
//
//  Created by Dennis Parussini on 01-11-16.
//  Copyright © 2016 Dennis Parussini. All rights reserved.
//

import UIKit

struct AlertManager {
    
    //MARK: - Display alert
    static func showAlert(withTitle title: String?, andMessage message: String, inViewController viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
