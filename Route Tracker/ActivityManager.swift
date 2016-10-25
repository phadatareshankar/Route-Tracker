//
//  ActivityManager.swift
//  Route Tracker
//
//  Created by Kc on 05/10/2016.
//  Copyright © 2016 Kenechi Okolo. All rights reserved.
//

import Foundation
import CoreLocation

protocol ActivityManagerDelegate: class {
    func updateMap()
    var gpsHorizontalAccuracy: Double { get set }
}

class ActivityManager: NSObject {
    
    // MARK: - API
    
    var isTracking: Bool { return routeActivity.active }
    var laps: [Lap] { return routeActivity.laps }
    var duration: TimeInterval { return routeActivity.duration ?? 0 }
    var currentLapDuration: TimeInterval? { return routeActivity.currentLap?.duration }
    var routeActivity = RouteActivity()
    
    var distance: Double { return routeActivity.distance }
    
    weak var delegate: ActivityManagerDelegate?
    
    // MARK: Activity Control - Start / Pause / Resume / End
    
    func startActivity() {
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
        previousActivities.append(routeActivity)
        routeActivity = RouteActivity()
        locationManager.stopUpdatingLocation()
    }
    
    func getCompletedActivity() -> RouteActivity? {
        guard let last = previousActivities.last else { return nil }
        guard last.completed else { return nil }
        return last
    }
    
    
    // MARK: - Initialization
    
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
    
    
    // MARK: - Private Properties
    
    fileprivate let locationManager = CLLocationManager()
    fileprivate var currentLocation: CLLocation!
    private var previousActivities: [RouteActivity] = []
    
    private var authorized: Bool {
        return CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse
    }
    
    
    // MARK: - Private functions
    
    private func requestAuthorization() {
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        switch authStatus {
        
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        
        default:
            break
        }
    }
}

// MARK: - Core Location Manager Delegate

extension ActivityManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        
        delegate?.gpsHorizontalAccuracy = currentLocation.horizontalAccuracy
        
        guard currentLocation.horizontalAccuracy < 50 else { return }
        
        delegate?.updateMap()
        
        guard routeActivity.active else { return }
        guard locations.count > 0 else { return }
        routeActivity.updatePosition(currentLocation: locations.last!)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to update location with error: \(error)")
    }
}
