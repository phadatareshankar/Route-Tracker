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
   
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    var activity: RouteActivity!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeLabel.text = "Time: " + TimerValue(seconds: activity.duration ?? 0).string
        distanceLabel.text = "Distance: " + String(activity.distance / 1000.00) + " km"
        setupMapView()
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.add(activity.routeDrawing)
    }

}

extension WorkoutCompleteViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 10.0
        renderer.strokeColor = UIColor.blue
        return renderer
    }
}
