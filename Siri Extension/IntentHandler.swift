//
//  IntentHandler.swift
//  Siri Extension
//
//  Created by Kc on 26/10/2016.
//  Copyright © 2016 Kenechi Okolo. All rights reserved.
//

import Intents

class IntentHandler: INExtension, INStartWorkoutIntentHandling  {
    
    let isWorkoutActive = UserDefaults.shared.bool(forKey: "isWorkoutActive")
    
    func handle(startWorkout intent: INStartWorkoutIntent, completion: @escaping (INStartWorkoutIntentResponse) -> Void) {
        
        
        
        if isWorkoutActive {
            let response = INStartWorkoutIntentResponse(code: .failureOngoingWorkout, userActivity: nil)
            completion(response)
            return
        }
        
        guard (intent.workoutName?.spokenPhrase) != nil else { return }
        
        
        let response = INStartWorkoutIntentResponse(code: .continueInApp, userActivity: nil)
        
        completion(response)
        
    }
    
}

extension IntentHandler: INPauseWorkoutIntentHandling {
    
    func handle(pauseWorkout intent: INPauseWorkoutIntent, completion: @escaping (INPauseWorkoutIntentResponse) -> Void) {
        
        guard isWorkoutActive else {
            let response = INPauseWorkoutIntentResponse(code: .failure, userActivity: nil)
            completion(response)
            return
        }
        
        let response = INPauseWorkoutIntentResponse(code: .continueInApp, userActivity: nil)
        
        completion(response)
    }
    
}

extension IntentHandler: INResumeWorkoutIntentHandling {
    func handle(resumeWorkout intent: INResumeWorkoutIntent, completion: @escaping (INResumeWorkoutIntentResponse) -> Void) {
        
        let response: INResumeWorkoutIntentResponse!
        
        guard UserDefaults.shared.bool(forKey: "isWorkoutPaused") else {
            response = INResumeWorkoutIntentResponse(code: .failure, userActivity: nil)
            completion(response)
            return
        }
        
        response = INResumeWorkoutIntentResponse(code: .continueInApp, userActivity: nil)
        completion(response)
    }
}

extension IntentHandler: INEndWorkoutIntentHandling {
    func handle(endWorkout intent: INEndWorkoutIntent, completion: @escaping (INEndWorkoutIntentResponse) -> Void) {
        guard isWorkoutActive else {
            let response = INEndWorkoutIntentResponse(code: .failure, userActivity: nil)
            completion(response)
            return
        }
        
        let response = INEndWorkoutIntentResponse(code: .continueInApp, userActivity: nil)
        
        completion(response)
    }
}

