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
    var startedAt: Date
    var endedAt: Date?
    
    var waypoints: [CLLocation]
    
    init(startTime: Date, startPosition: CLLocation) {
        self.startedAt = startTime
        self.waypoints = [startPosition]
    }
    
    func logWayPoint(currentLocation: CLLocation) {
        waypoints.append(currentLocation)
    }
    
    func end(finalPosition: CLLocation) {
        logWayPoint(currentLocation: finalPosition)
        endedAt = Date()
    }
}
