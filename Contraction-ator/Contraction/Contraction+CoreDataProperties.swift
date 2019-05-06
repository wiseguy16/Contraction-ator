//
//  Contraction+CoreDataProperties.swift
//  Contraction-ator
//
//  Created by Greg Weiss on 3/13/18.
//  Copyright © 2018 Greg Weiss. All rights reserved.
//
//

import Foundation
import CoreData


extension Contraction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contraction> {
        let request = NSFetchRequest<Contraction>(entityName: Contraction.EntityName)
        request.sortDescriptors = [NSSortDescriptor(key: "dateHadStarted", ascending: false)]
        return request
    }

    @NSManaged public var duration: Double
    @NSManaged public var dateHadStarted: Date?
    @NSManaged public var note: String?
    @NSManaged public var timeSinceLast: Double
    @NSManaged public var dialation: Int
    @NSManaged public var dateHadFinished: Date?
    @NSManaged public var averageTimeApart: Double
    @NSManaged public var averageDuration: Double
    @NSManaged public var lastContractionStamp: Date?
    

}
