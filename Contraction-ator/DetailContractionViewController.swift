//
//  DetailContractionViewController.swift
//  Contraction-ator
//
//  Created by Greg Weiss on 3/17/18.
//  Copyright © 2018 Greg Weiss. All rights reserved.
//

import UIKit
import CoreData
import Charts

class DetailContractionViewController: UIViewController {
    
    var context: NSManagedObjectContext?
    var contractions: [Contraction] = []
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var combChartView: CombinedChartView!
    
    lazy var frc: NSFetchedResultsController<Contraction> = {
        let request: NSFetchRequest<Contraction> = Contraction.fetchRequest()
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.context!, sectionNameKeyPath: nil, cacheName: nil)
        return controller
    }()

    @IBOutlet weak var durationLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControl.selectedSegmentIndex = 0
        
        frc.delegate = self
        
        do {
            try frc.performFetch()
            if let objects = frc.fetchedObjects {
                contractions = objects
                for obj in objects {
                    print("obj.duration >> \(obj.duration)")
                }
            }
        } catch {
            print("Error fetching Contraction objects: \(error.localizedDescription)")
        }
        combChartView.chartDescription?.enabled = false
        
        let l = combChartView.legend
        l.wordWrapEnabled = true
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        
        setChartData()

    }
    
    @IBAction func segmentTapped(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            combChartView.xAxis.axisMinimum = -30.0
            setChartData(xMinimun: -30.0)
        }
        if sender.selectedSegmentIndex == 1 {
            combChartView.xAxis.axisMinimum = -60.0
            setChartData(xMinimun: -60.0)
        }
        if sender.selectedSegmentIndex == 2 {
            setChartData(xMinimun: -120.0)
        }
        if sender.selectedSegmentIndex == 3 {
            setChartData(xMinimun: -1440.0)
        }
    }
    
    
    func setChartData(xMinimun: Double = -30.0) {
        let data = CombinedChartData()
        data.barData = generateBarData()
        data.lineData = generateLineData()

        combChartView.xAxis.axisMaximum = 0.0
        combChartView.xAxis.axisMinimum = xMinimun
        
        combChartView.data = data
        
    }
    
    func generateBarData() -> BarChartData {
        var entries: [BarChartDataEntry] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"

        for cont in contractions {
            var xPos: Double = 0.0
            if let dateHadStarted = cont.dateHadStarted {
                print("\(dateHadStarted)")
                let xxPos = dateHadStarted.timeIntervalSince(Date())
                xPos = (xxPos * 1.667)/100
            }
            
            let entry = BarChartDataEntry(x: xPos, y: (cont.duration))
            entries.append(entry)
        }
        let nowEntry = BarChartDataEntry(x: 0.0, y: 0.0)
        entries.append(nowEntry)

        let set1 = BarChartDataSet(values: entries, label: "Duration")
        
        set1.setColor(UIColor(red: 60/255, green: 220/255, blue: 78/255, alpha: 1))
        set1.valueTextColor = UIColor(red: 60/255, green: 220/255, blue: 78/255, alpha: 1)
        set1.valueFont = .systemFont(ofSize: 12)
        set1.axisDependency = .left
        
        let barWidth = 0.25
        
        let data = BarChartData(dataSets: [set1])
        data.barWidth = barWidth
        
        return data
    }
    
    func generateLineData() -> LineChartData {
 
        var lineEntries: [ChartDataEntry] = []
        
        for cont in contractions {
            var xPos: Double = 0.0
            if let dateHadStarted = cont.dateHadStarted {
                print("\(dateHadStarted)")
                let xxPos = dateHadStarted.timeIntervalSince(Date())
                xPos = (xxPos * 1.667)/100
            }
            
            let entry = ChartDataEntry(x: xPos, y: Double(cont.dialation))
            lineEntries.append(entry)
        }
        
        let set = LineChartDataSet(values: lineEntries.reversed(), label: "Intensity")
        set.setColor(UIColor(red: 240/255, green: 238/255, blue: 70/255, alpha: 1))
        set.lineWidth = 3.0
        set.setCircleColor(UIColor(red: 240/255, green: 238/255, blue: 70/255, alpha: 1))
        set.circleRadius = 7.5
        set.circleHoleRadius = 4.5
        set.fillColor = UIColor(red: 240/255, green: 238/255, blue: 70/255, alpha: 1)
        set.mode = .cubicBezier
        set.drawValuesEnabled = true
        set.valueFont = .systemFont(ofSize: 12)
        set.valueTextColor = UIColor(red: 240/255, green: 238/255, blue: 70/255, alpha: 1)
        
        set.axisDependency = .left
        return LineChartData(dataSet: set)
    }

}

extension DetailContractionViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //tableView.reloadData()
        if let _ = frc.fetchedObjects {
            print("Got objects")
           // contractions = objects
        }
    }
    
}
