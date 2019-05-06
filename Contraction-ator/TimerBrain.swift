//
//  TimerBrain.swift
//  Contraction-ator
//
//  Created by Greg Weiss on 3/14/18.
//  Copyright © 2018 Greg Weiss. All rights reserved.
//

import UIKit
import CoreData


public class TimerBrain {
    
    static let shared = TimerBrain()
    
    var sampleText = ""
    
    var babyTimer = Timer()
    var isTimerRunning = false
    var seconds = 0
    var pauseTapped = false
    
    func resetTimer(label: UILabel) {
        babyTimer.invalidate()
        seconds = 0
        label.text = "00:00"
        isTimerRunning = false
    }
    

    
    static func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let secondz = Int(time) % 60
        
        let word = String(format: "%02i:%02i:%02i", hours, minutes, secondz)
        return word
    }
    
    
    
    static func shortTimeString(time: TimeInterval) -> String {
        //let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let secondz = Int(time) % 60
        
        let word = String(format: "%02i:%02i", minutes, secondz)
        return word
    }
    
    static func convertIntensity(currentValue: Int) -> String {
        var intensity = "light"
        switch currentValue {
        case 1...2:
            intensity = "light"
        case 3...5:
            intensity = "medium"
        case 6...8:
            intensity = "strong"
        case 9...10:
            intensity = "severe"
        default:
            intensity = "light"
        }
        return intensity
    }
    
    
}
