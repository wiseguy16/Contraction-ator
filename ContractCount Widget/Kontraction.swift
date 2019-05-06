//
//  Kontraction.swift
//  ContractCount Widget
//
//  Created by Greg Weiss on 3/15/18.
//  Copyright © 2018 Greg Weiss. All rights reserved.
//

import Foundation

public class Kontraction {
    
     var duration: Double?
     var dateHadStarted: Date?
     var note: String?
     var timeSinceLast: Double?
     var intensity: Int?
     var dateHadFinished: Date?
     var averageTimeApart: Double?
     var averageDuration: Double?
     var lastContractionStamp: Date?
     var UUID: String? //NSUUID().uuidString
    
    init(dict: [String: Any]) {
        self.duration = dict["duration"] as? Double
        self.dateHadStarted = dict["dateHadStarted"] as? Date
        self.note = dict["note"] as? String
        self.timeSinceLast = dict["timeSinceLast"] as? Double
        //self.intensity = dict["intensity"] as? Int
        self.dateHadFinished = dict["dateHadFinished"] as? Date
        self.averageTimeApart = dict["averageTimeApart"] as? Double
        self.averageDuration = dict["averageDuration"] as? Double
        self.lastContractionStamp = dict["lastContractionStamp"] as? Date
        self.UUID = dict["UUID"] as? String
    }
}
