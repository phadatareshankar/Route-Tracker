//
//  RouteActivity.swift
//  Route Tracker
//
//  Created by Kc on 05/10/2016.
//  Copyright © 2016 Kenechi Okolo. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

struct RouteActivity {
    
    private (set) var laps: [Lap] = []
    
    mutating func newLap(location: CLLocation, startTime: Date = Date()) {
        let lap = Lap(startTime: startTime, startPosition: location)
        laps.append(lap)
    }
    
    func pause() {
        currentLap?.pause()
    }
    
    func resume() {
        currentLap?.resume()
    }
    
    func end(location: CLLocation) {
        laps.last?.end(finalPosition: location)
    }
    
    func updatePosition(currentLocation: CLLocation) {
        currentLap?.logWayPoint(currentLocation: currentLocation)
        print("Waypoints: \(currentLap?.waypoints)")
    }
    
    mutating func logLap(currentLocation: CLLocation) {
        currentLap?.end(finalPosition: currentLocation)
        guard let time = lastLap?.endedAt else { fatalError("Current lap: \(currentLap), should have an end time") }
        newLap(location: currentLocation, startTime: time)
    }
    
    var active: Bool {
        return startedAt != nil && endedAt == nil
    }
    
    var startedAt: Date? {
        return laps.first?.startedAt
    }
    
    var endedAt: Date? {
        return laps.last?.endedAt
    }
    
    var pausedTime: TimeInterval {
        var total: TimeInterval = 0
        for lap in laps { total += lap.pausedTime }
        return total
    }
    
    var distance: Double {
        var total: Double = 0
        for lap in laps { total += Double(lap.distance) }
        return total
    }
    
    var duration: TimeInterval? {
        guard let start = startedAt else { return nil }
        let end = endedAt ?? Date()
        return end.timeIntervalSince(start) - pausedTime
    }
    
    var completed: Bool {
        return startedAt != nil && endedAt != nil
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
    
    var routeDrawing: MKPolyline {
        var waypoints: [CLLocationCoordinate2D] = []
        for lap in laps {
            waypoints += lap.waypoints.map { $0.coordinate }
        }
        if waypoints.count > 0 { waypoints.removeFirst() }
        return MKPolyline(coordinates: waypoints, count: waypoints.count)
    }
    
}
