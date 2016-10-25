//
//  WorkoutCompleteViewController.swift
//  Route Tracker
//
//  Created by Kc on 07/10/2016.
//  Copyright © 2016 Kenechi Okolo. All rights reserved.
//

import UIKit
import MapKit

class WorkoutCompleteViewController: UIViewController {
    
    
    // MARK: - API
    
    var activity: RouteActivity!
    
    
    // MARK: - Interface Builder Actions & Outlets
   
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeLabel.text = "Time: " + TimerValue(seconds: activity.duration ?? 0).string
        distanceLabel.text = "Distance: " + String(activity.distance / 1000.00) + " km"
        setupMapView()
    }
    
    
    // MARK: - Helper Functions
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.add(activity.routeDrawing)
        mapView.showAnnotations([activity.routeDrawing], animated: false)
    }

}


// MARK: - Map View Delegate

extension WorkoutCompleteViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 10.0
        renderer.strokeColor = UIColor.blue
        return renderer
    }
}
