//
//  TodayViewController.swift
//  ContractCount Widget
//
//  Created by Greg Weiss on 3/12/18.
//  Copyright © 2018 Greg Weiss. All rights reserved.
//

import UIKit
import CoreData
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var lastContrctLabel: UILabel!
    @IBOutlet weak var lastIntervalLabel: UILabel!
    @IBOutlet weak var avgIntervalLabel: UILabel!
    @IBOutlet weak var avgDurationLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
   // let brain2 = UserDefaults.standard
    let widgetDefaults = UserDefaults(suiteName: "group.com.gergusa04.Contraction-ator")!

    
   
    
    var babyTimer = Timer()
    var isTimerRunning = false
    var seconds = 0
    var pauseTapped = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.layer.cornerRadius = 10
        startButton.layer.masksToBounds = true
        
        
        durationLabel.layer.cornerRadius = 4
        durationLabel.layer.masksToBounds = true
        print("Widget viewDidLoad()")
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       print("Widget viewDidAppear())")
    }
    

    
    @IBAction func buttonTapped(_ sender: UIButton) {
        if pauseTapped && isTimerRunning {
            // Finished a Contraction & hitting Stop
            babyTimer.invalidate()
            isTimerRunning = false
            storeContraction()
        } else if pauseTapped && !isTimerRunning {
            // All other times Starting
            resetTimer()
            setupAndStartTimer()
            UserDefaults.standard.set(Date(), forKey: "MarkedContraction")
            UserDefaults.standard.synchronize()
        } else {
            // First time through
            setupAndStartTimer()
            pauseTapped = true
        }
        
        adjustButton()
        
    }
    
    func storeContraction() {
        let duration = TimeInterval(seconds)
        //brain.sampleText = "\(duration)"
        
        widgetDefaults.set(duration, forKey: "WidgetTimerDuration")
        
        /*
        contraction.duration = duration
        contraction.dateHadStarted = (Date() - duration)
        contraction.dateHadFinished = Date()
        
    
        */
    }
    
    func shortTimeString(time: TimeInterval) -> String {
        //let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let secondz = Int(time) % 60
        
        let word = String(format: "%02i:%02i", minutes, secondz)
        return word
    }
    

    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let expanded = activeDisplayMode == .expanded
        preferredContentSize = expanded ? CGSize(width: maxSize.width, height: 200) : maxSize
        print("Widget widgetActiveDisplayModeDidChange()")
        
 
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        print("Widget widgetPerformUpdate()")
        widgetDefaults.synchronize()
        let todoDictionary = widgetDefaults.dictionary(forKey: "ITEMS_KEY") ?? [:]
        let kon = Kontraction(dict: todoDictionary)
        //lastContrctLabel.text = "\(kon.lastContractionStamp ?? Date())"
        //lastIntervalLabel.text = "\(kon.timeSinceLast ?? 0.0)"
        //avgDurationLabel.text = "\(kon.averageDuration ?? 0.0)"
        //avgIntervalLabel.text = "\(kon.averageTimeApart ?? 0.0)"
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        guard let contractionDate = kon.dateHadStarted else { return  }
        let dayHad = dateFormatter.string(from: contractionDate)
        //cell.dateHadLabel.text = dayHad
        
        let length = shortTimeString(time: kon.duration ?? 0.0)
        lastContrctLabel.text = "\(length)"
        //cell.intensityLabel.text = "intensity : 4"
        let previous = timeString(time: kon.timeSinceLast ?? 0.0)
        lastIntervalLabel.text = "\(previous)"
        let avgCntrct = shortTimeString(time: kon.averageDuration ?? 0.0)
        avgDurationLabel.text = "\(avgCntrct)"
        var avgInterval = timeString(time: kon.averageTimeApart ?? 0.0)
        let parts = avgInterval.components(separatedBy: ":")
        if parts.first == "00" {
            avgInterval.remove(at: avgInterval.startIndex)
            avgInterval.remove(at: avgInterval.startIndex)
            avgInterval.remove(at: avgInterval.startIndex)
        }
        avgIntervalLabel.text = "\(avgInterval)"

        

//        let cntrtDuration = widgetDefaults.double(forKey: "WidgetLastDuration")
//        let length = shortTimeString(time: (cntrtDuration))
//        lastContrctLabel.text = "\(length)"
    
        self.view.setNeedsDisplay()
        completionHandler(NCUpdateResult.newData)
    }
    
    
    func resetTimer() {
        babyTimer.invalidate()
        seconds = 0
        durationLabel.text = "00:00"
        isTimerRunning = false
    }
    
    func setupAndStartTimer() {
        if !isTimerRunning {
            babyTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLabelAndCounter), userInfo: nil, repeats: true)
            isTimerRunning = true
        }
    }
    
    func adjustButton() {
        if isTimerRunning {
            startButton.setTitle("STOP", for: .normal)
            startButton.backgroundColor = .red
            durationLabel.backgroundColor = .yellow
        } else {
            startButton.setTitle("START", for: .normal)
            startButton.backgroundColor = .blue
            durationLabel.backgroundColor = .clear
        }
    }
    
    @objc func updateLabelAndCounter() {
        seconds += 1
        durationLabel.text = shortTimeString(time: TimeInterval(seconds))
    }
    
    func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let secondz = Int(time) % 60
        
        let word = String(format: "%02i:%02i:%02i", hours, minutes, secondz)
        return word
    }
    
    
}


