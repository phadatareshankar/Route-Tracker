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
    @IBOutlet weak var rightButton: OvalButton! { didSet { rightButton.delegate = self } }
    @IBOutlet weak var leftButton: OvalButton! { didSet { leftButton.delegate = self } }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var timeDisplay: UILabel!
    
    @IBAction func rightButtonTapped(_ sender: UIButton) {
        guard routeTracker.isTracking else { return }
        routeTracker.newLap()
        tableView.reloadData()
    }
    
    private var timer: Timer!
    
    fileprivate func start() {
        routeTracker.startActivity()
        startDisplayTimer()
    }
    
    fileprivate func pause() {
        routeTracker.pauseActivity()
        timer.invalidate()
    }
    
    fileprivate func resume() {
        routeTracker.resumeActivity()
        startDisplayTimer()
    }
    
    fileprivate func newLap() {
        routeTracker.newLap()
        tableView.reloadData()
    }
    
    fileprivate func end() {
        routeTracker.endActivity()
        timer.invalidate()
    }
    
    private func startDisplayTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true, block: { [unowned self] _ in
            self.timeDisplay.text = TimerValue(seconds: self.routeTracker.duration).string
            })
    }
    
    fileprivate let routeTracker = ActivityManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        
    }
    
    private func setupMapView() {
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
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

extension RouteTrackingViewController: OvalButtonDelegate {
    
    func buttonTapped(button: OvalButton) {
        
        switch button.identifier {
            
        case "Start":
            start()
            guard routeTracker.isTracking else { return }
            button.configure(title: "Pause")
            
        case "Pause":
            pause()
            rightButton.configure(title: "End", color: UIColor(red: 0.851, green: 0.298, blue: 0.392, alpha: 0.8))
            button.configure(title: "Resume")
            
        case "Resume":
            resume()
            guard routeTracker.isTracking else { return }
            rightButton.configure(title: "New Lap")
            button.configure(title: "Pause")
            
        case "New Lap":
            guard routeTracker.isTracking else { return }
            newLap()
            
        case "End":
            end()
            button.configure(title: "New Lap")
            leftButton.configure(title: "Start")
            
        default:
            break
        }
    }
}

extension RouteTrackingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return max(routeTracker.laps.count - 1, 0) // so it never shows current lap
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Lap Detail", for: indexPath) as! LapDetailCell
        
        cell.titleLabel?.text = "Lap " + String(indexPath.row + 1)
        guard routeTracker.laps.count > 0 else { return cell }
        cell.durationLabel?.text =  TimerValue(seconds: routeTracker.laps[indexPath.row].duration).string
        cell.distanceLabel.text = String(routeTracker.laps[indexPath.row].distance / 1000.00) + "km"
        
        return cell
    }
}

extension RouteTrackingViewController: MKMapViewDelegate {
    
}

struct TimerValue {
    
    init(seconds: Double) {
        self.value.h = Int(seconds / 3600.0)
        self.value.m = (Int(seconds) % 3600) / 60
        self.value.s = seconds.truncatingRemainder(dividingBy: 60)
    }
    
    var value: (h: Int, m: Int, s: Double)
    
    var string: String {
        let hours = String(format: "%02i", value.0)
        let minutes = String(format: "%02i", value.1)
        let seconds = String(format: "%06.3f", value.2)
        return hours + ":" + minutes + ":" + seconds
    }
}

extension TimeInterval {
    func timerValue() -> (Int, Int, Double) {
        return (Int(self / 3600.0), (Int(self) % 3600) / 60, self.truncatingRemainder(dividingBy: 60))
    }
}
