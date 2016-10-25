//
//  RouteTrackingViewController.swift
//  Route Tracker
//
//  Created by Kc on 05/10/2016.
//  Copyright © 2016 Kenechi Okolo. All rights reserved.
//

import UIKit
import MapKit

// MARK: - Enum Declaration

enum GoalType {
    case basic
    case distance
    case time
    
    var title: String {
        switch self {
        case .basic:
            return "Basic"
        case .distance:
            return "Distance"
        case .time:
            return "Time"
        }
    }
}

// MARK: - Class Declaration

class RouteTrackingViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private var timer: Timer!
    
    fileprivate var goal: GoalType = .basic { didSet { title = goal.title } }
    fileprivate var goalValue: Double!
    fileprivate let routeTracker = ActivityManager()
    
    internal var gpsHorizontalAccuracy: Double = 100
    
   
    // MARK: - Interface Builder Outlets
    
    @IBOutlet weak var rightButton: OvalButton! { didSet { rightButton.delegate = self } }
    @IBOutlet weak var leftButton: OvalButton! { didSet { leftButton.delegate = self } }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var timeDisplay: UILabel!
    @IBOutlet weak var activityTypeBarButton: UIBarButtonItem!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        routeTracker.delegate = self
    }

    
    // MARK: - Interface Builder Actions / UI Actions
    
    @IBAction func activityTypeButtonTapped(_ sender: UIBarButtonItem) {
        let activityTypeAlert = UIAlertController(title: "Choose Goal", message: nil, preferredStyle: .actionSheet)
        activityTypeAlert.addAction(UIAlertAction(title: "Basic", style: .default, handler: {_ in
            self.goal = .basic
        }))
        activityTypeAlert.addAction(UIAlertAction(title: "Distance", style: .default, handler: {_ in
            self.goal = .distance
            self.presentGoalAlert(for: self.goal)
        }))
        activityTypeAlert.addAction(UIAlertAction(title: "Time", style: .default, handler: {_ in
            self.goal = .time
            self.presentGoalAlert(for: self.goal)
        }))
        
        present(activityTypeAlert, animated: true, completion: nil)
    }
    
    private func presentGoalAlert(for type: GoalType) {
        
        let alert = UIAlertController(title: "Set Goal", message: "Choose a \(type.title)", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.delegate = self
            textField.keyboardType = .numberPad
            textField.returnKeyType = .done
        })
        
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
           alert.textFields?.first?.resignFirstResponder()
        }))
        
        if type == .distance {
            alert.title = "Set Goal (in km)"
        } else {
            alert.title = "Set Goal (in minutes)"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Route Tracking Functions
    
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
        performSegue(withIdentifier: "Workout Complete", sender: self)
    }
    
    // MARK: - Helper Functions
    
    private func startDisplayTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true, block: { [unowned self] _ in
            self.displayUpdatedTime()
            })
    }
    
    fileprivate func displayUpdatedTime() {
        var timeToDisplay: Double
        self.goal == .time ? (timeToDisplay = self.goalValue - self.routeTracker.duration) : (timeToDisplay = self.routeTracker.duration)
        
        self.timeDisplay.text = TimerValue(seconds: timeToDisplay).string
    }
    
    private func setupMapView() {
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "Workout Complete" else { return }
        guard let navVC = segue.destination as? UINavigationController else { return }
        guard let workoutCompleteVC = navVC.topViewController as? WorkoutCompleteViewController else { return }
        
        workoutCompleteVC.activity = routeTracker.getCompletedActivity()
        workoutCompleteVC.mapView = MKMapView()
        
    }
 

}

extension RouteTrackingViewController: OvalButtonDelegate {
    
    func buttonTapped(button: OvalButton) {
        
        if gpsHorizontalAccuracy > 50 {
            let alert = UIAlertController(title: "GPS Signal Weak", message: "The GPS signal is too weak (error: +/- \(gpsHorizontalAccuracy)m) to give accurate readings. Please wait for a better signal", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
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
        cell.distanceLabel.text = String(Double(routeTracker.laps[indexPath.row].distance) / 1000.00) + "km"
        
        return cell
    }
}

extension RouteTrackingViewController: ActivityManagerDelegate {
    func updateMap() {
        updateGoal()
        
        guard routeTracker.isTracking else { return }
        mapView.add(routeTracker.routeActivity.routeDrawing)
    }
    
    func updateGoal() {
        var goalRemaining: Double
        
        switch goal {
        
        case .distance:
            goalRemaining = goalValue - routeTracker.distance
            
        case .time:
            goalRemaining = goalValue - routeTracker.duration
            
        case .basic:
            goalRemaining = 0
        }
        
        guard goalRemaining < 0 else { return }
        
        end()
    }
}

extension RouteTrackingViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 10.0
        return renderer
    }
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

extension RouteTrackingViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if text.isEmpty {
            goalValue = 600
            return
        }
        
        if goal == .distance {
            goalValue = Double(text)!
        } else {
            goalValue = Double(text)! * 60
        }
        
        displayUpdatedTime()
        
    }
}
