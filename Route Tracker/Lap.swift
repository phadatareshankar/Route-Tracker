//
//  Lap.swift
//  Route Tracker
//
//  Created by Kc on 05/10/2016.
//  Copyright © 2016 Kenechi Okolo. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class Lap {
    
    
    // MARK: - Variables
    
    var startedAt: Date
    var endedAt: Date?
    
    var pausedTime: TimeInterval = 0
    var pausedAt: Date?
    
    var waypoints: [CLLocation]
    
   
    // MARK: - Initialization
    
    init(startTime: Date, startPosition: CLLocation) {
        self.startedAt = startTime
        self.waypoints = [startPosition]
    }
    
    
    // MARK: - Computed Variables
    
    var duration: TimeInterval {
        let end = endedAt ?? Date()
        return end.timeIntervalSince(startedAt) - pausedTime
    }
    
    
    var distance: Int {
        var total: Double = 0
        
        for (i, waypoint) in waypoints.enumerated() {
            if i + 1 < waypoints.endIndex {
                let increment = waypoint.distance(from: waypoints[i + 1])
                total += increment
            }
        }
        
        return Int(total.rounded())
    }
    
    
    // MARK: - Functions
    
    func logWayPoint(currentLocation: CLLocation) {
        waypoints.append(currentLocation)
    }
    
    func pause(time: Date = Date()) {
        pausedAt = time
    }
    
    func resume(time: Date = Date()) {
        guard let pause = pausedAt else { return }
        pausedTime += time.timeIntervalSince(pause)
        pausedAt = nil
    }
    
    func end(finalPosition: CLLocation) {
        logWayPoint(currentLocation: finalPosition)
        
        if let _ = pausedAt { resume() }
        
        endedAt = Date()
    }
}
