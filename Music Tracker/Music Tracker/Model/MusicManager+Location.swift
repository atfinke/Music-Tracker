//
//  MusicManager+Location.swift
//  Music Tracker
//
//  Created by Andrew Finke on 4/1/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import CoreLocation

extension MusicManager: CLLocationManagerDelegate {
    
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers

        locationManager.showsBackgroundLocationIndicator = true
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false

        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Updated Location")
    }
}
