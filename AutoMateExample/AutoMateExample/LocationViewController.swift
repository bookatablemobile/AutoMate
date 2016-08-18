//
//  LocationVIewController.swift
//  AutoMateExample
//
//  Created by Pawel Szot on 18/08/16.
//  Copyright © 2016 PGS Software. All rights reserved.
//

import UIKit
import CoreLocation

class LocationViewController: UIViewController, CLLocationManagerDelegate {
    // MARK: - IBOutlets
    @IBOutlet var label: UILabel!
    let manager = CLLocationManager()

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        updateStatus()
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        updateStatus()
    }

    // MARK: - Helpers
    func updateStatus() {
        let status = CLLocationManager.authorizationStatus()
        label.text = status == .Denied ? "Denied" : "X"
    }
}
