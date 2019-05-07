//
//  Contraktion.swift
//  Contraction-ator
//
//  Created by Greg Weiss on 3/17/18.
//  Copyright © 2018 Greg Weiss. All rights reserved.
//

import Foundation

public class Contraktion {
    
    var duration: Double?
    var dateHadStarted: Date?
    var note: String?
    var timeSinceLast: Double?
    var intensity: Int64?
    var dateHadFinished: Date?
    var averageTimeApart: Double?
    var averageDuration: Double?
    var lastContractionStamp: Date?
    var UUID: String? 
    
    init(dict: [String: Any]) {
        self.duration = dict["duration"] as? Double
        self.dateHadStarted = dict["dateHadStarted"] as? Date
        self.note = dict["note"] as? String
        self.timeSinceLast = dict["timeSinceLast"] as? Double
        self.intensity = dict["intensity"] as? Int64
        self.dateHadFinished = dict["dateHadFinished"] as? Date
        self.averageTimeApart = dict["averageTimeApart"] as? Double
        self.averageDuration = dict["averageDuration"] as? Double
        self.lastContractionStamp = dict["lastContractionStamp"] as? Date
        self.UUID = dict["UUID"] as? String
    }
    
    init() {
        self.duration = 0.0
        self.dateHadStarted = Date()
        self.note = ""
        self.timeSinceLast = 0.0
        self.intensity = 1
        self.dateHadFinished = Date()
        self.averageTimeApart = 0.0
        self.averageDuration = 0.0
        self.lastContractionStamp = Date()
        self.UUID = ""
    }
    
    static func contraktionToDict(contrak: Contraktion) -> [String: Any] {
        var contDict: [String: Any] = [:]
        contDict["duration"] = contrak.duration
        contDict["dateHadStarted"] = contrak.dateHadStarted
        contDict["note"] = contrak.note
        contDict["timeSinceLast"] = contrak.timeSinceLast
        contDict["intensity"] = contrak.intensity
        contDict["dateHadFinished"] = contrak.dateHadFinished
        contDict["averageTimeApart"] = contrak.averageTimeApart
        contDict["averageDuration"] = contrak.averageDuration
        contDict["lastContractionStamp"] = contrak.lastContractionStamp
        contDict["UUID"] = contrak.UUID
        return contDict
        
    }
}
