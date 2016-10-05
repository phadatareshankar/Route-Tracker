//
//  RouteActivity.swift
//  Route Tracker
//
//  Created by Kc on 05/10/2016.
//  Copyright © 2016 Kenechi Okolo. All rights reserved.
//

import Foundation
import CoreLocation

class RouteActivity {
    
    private var laps: [Lap] = []
    
    
    func newLap(location: CLLocation, startTime: Date = Date()) {
        let lap = Lap(startTime: startTime, startPosition: location)
        laps.append(lap)
    }
    
    func end(location: CLLocation) {
        laps.last?.end(finalPosition: location)
    }
    
    func updatePosition(currentLocation: CLLocation) {
        currentLap?.logWayPoint(currentLocation: currentLocation)
    }
    
    func logLap(currentLocation: CLLocation) {
        currentLap?.end(finalPosition: currentLocation)
        guard let time = currentLap?.endedAt else { fatalError("Current lap: \(currentLap), should have an end time") }
        newLap(location: currentLocation, startTime: time)
    }
    
    var active: Bool {
        return endedAt == nil
    }
    
    var startedAt: Date? {
        return laps.first?.startedAt
    }
    
    var endedAt: Date? {
        return laps.last?.endedAt
    }
    
    var duration: TimeInterval? {
        guard let start = startedAt, let end = endedAt else { return nil }
        return end.timeIntervalSince(start)
    }
    
    var startPosition: CLLocation? {
        return laps.first?.waypoints.first
    }
    
    var currentLap: Lap? {
        guard let lap = laps.last else { return nil }
        guard lap.endedAt == nil else { return nil } // make sure lap hasn't ended
        return lap
    }
    
    var lastLap: Lap? {
        return laps.last
    }
    
    var lastPosition: CLLocation? {
        return laps.last?.waypoints.last
    }
    
}
