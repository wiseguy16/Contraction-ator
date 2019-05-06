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
       // durationLabel.text = "\(contrctn.duration)"
        
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
            //self.view.setNeedsDisplay()
            setChartData(xMinimun: -30.0)
            

        }
        if sender.selectedSegmentIndex == 1 {
            combChartView.xAxis.axisMinimum = -60.0
            //self.view.setNeedsDisplay()
            setChartData(xMinimun: -60.0)
        }
        if sender.selectedSegmentIndex == 2 {
           // combChartView.xAxis.axisMinimum = -120.0
            setChartData(xMinimun: -120.0)
        }
        if sender.selectedSegmentIndex == 3 {
            // combChartView.xAxis.axisMinimum = -120.0
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
            print("xPos>> \(xPos)\n")
            
            let entry = BarChartDataEntry(x: xPos, y: (cont.duration))
            entries.append(entry)
        }
        let nowEntry = BarChartDataEntry(x: 0.0, y: 0.0)
        entries.append(nowEntry)

        
        let entries3 = [BarChartDataEntry(x: 1, y: 1),
                        BarChartDataEntry(x: 2, y: 2),
                        BarChartDataEntry(x: 3, y: 2),
                        BarChartDataEntry(x: 4, y: 3),
                        BarChartDataEntry(x: 5, y: 5),
                        BarChartDataEntry(x: 6, y: 7),
                        BarChartDataEntry(x: 9, y: 9),
                        BarChartDataEntry(x: 8, y: 8)]
        
        
        let set1 = BarChartDataSet(values: entries, label: "Duration")
        
        set1.setColor(UIColor(red: 60/255, green: 220/255, blue: 78/255, alpha: 1))
        set1.valueTextColor = UIColor(red: 60/255, green: 220/255, blue: 78/255, alpha: 1)
        set1.valueFont = .systemFont(ofSize: 12)
        set1.axisDependency = .left
        
        let groupSpace = 0.06
        let barSpace = 0.02 // x2 dataset
        let barWidth = 0.25 // x2 dataset
        
        let data = BarChartData(dataSets: [set1])
        data.barWidth = barWidth
        
        // make this BarData object grouped
        //data.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
        
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
            print("xPos>> \(xPos)\n")
            print("Dialation >> \(Double(cont.dialation)*10)")
            
            let entry = ChartDataEntry(x: xPos, y: Double(cont.dialation))
            lineEntries.append(entry)
        }
        let lns = [ChartDataEntry(x: 1.1, y: 8.5),
                   ChartDataEntry(x: 2.1, y: 7.5),
                   ChartDataEntry(x: 4.1, y: 7.8),
                   ChartDataEntry(x: 5.1, y: 11.5),
                   ChartDataEntry(x: 8.1, y: 6.5),
                   ChartDataEntry(x: 9.1, y: 6.5),
                   ChartDataEntry(x: 11.1, y: 5.5)]
        
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
        if let objects = frc.fetchedObjects {
            print("Got objects")
           // contractions = objects
        }
    }
    
}
