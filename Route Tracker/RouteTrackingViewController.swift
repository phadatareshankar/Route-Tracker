//
//  RouteTrackingViewController.swift
//  Route Tracker
//
//  Created by Kc on 05/10/2016.
//  Copyright © 2016 Kenechi Okolo. All rights reserved.
//

import UIKit
import MapKit

class RouteTrackingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RouteTrackingViewController: UITableViewDelegate {
    
}

extension RouteTrackingViewController: UITableViewDataSource {
    
}

extension RouteTrackingViewController: MKMapViewDelegate {
    
}
