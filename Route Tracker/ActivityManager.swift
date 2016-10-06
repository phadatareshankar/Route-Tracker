//
//  ActivityManager.swift
//  Route Tracker
//
//  Created by Kc on 05/10/2016.
//  Copyright © 2016 Kenechi Okolo. All rights reserved.
//

import Foundation
import CoreLocation

class ActivityManager: NSObject, CLLocationManagerDelegate {
    
    var isTracking: Bool { return routeActivity.active }
    
    private let locationManager = CLLocationManager()
    
    private var currentLocation: CLLocation!
    private var routeActivity: RouteActivity!
    
    var laps: [Lap] { return routeActivity.laps }
    var duration: TimeInterval { return routeActivity.duration ?? 0 }
    var currentLapDuration: TimeInterval? { return routeActivity.currentLap?.duration }
    var distance: Double { return routeActivity.distance }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if !authorized {
            requestAuthorization()
            return
        }
        
        guard CLLocationManager.locationServicesEnabled() else { return }
        
        locationManager.requestLocation()
    }
    
    func startActivity() {
        routeActivity = RouteActivity()
        locationManager.startUpdatingLocation()
        guard let location = currentLocation else { return }
        routeActivity.newLap(location: location)
    }
    
    func pauseActivity() {
        locationManager.stopUpdatingLocation()
        routeActivity.pause()
    }
    
    func resumeActivity() {
        locationManager.startUpdatingLocation()
        routeActivity.resume()
    }
    
    func newLap() {
        routeActivity.logLap(currentLocation: currentLocation)
    }
    
    func endActivity() {
        guard let location = currentLocation else { return }
        routeActivity.end(location: location)
        locationManager.stopUpdatingLocation()
    }
    
    private var authorized: Bool {
        return CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse
    }
    
    private func requestAuthorization() {
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        switch authStatus {
        
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        
        guard routeActivity.active else { return }
        guard locations.count > 0 else { return }
        routeActivity.updatePosition(currentLocation: locations.last!)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to update location with error: \(error)")
    }
    
    
}
