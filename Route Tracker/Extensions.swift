//
//  Extensions.swift
//  Route Tracker
//
//  Created by Kc on 26/10/2016.
//  Copyright © 2016 Kenechi Okolo. All rights reserved.
//

import Foundation

extension UserDefaults {
    static var shared: UserDefaults {
        return UserDefaults(suiteName: "group.kenechilearnscode.routeTracker")!
    }
}
