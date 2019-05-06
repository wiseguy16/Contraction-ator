//
//  ViewController.swift
//  Contraction-ator
//
//  Created by Greg Weiss on 3/12/18.
//  Copyright © 2018 Greg Weiss. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer

let level0:UIColor = #colorLiteral(red: 0.7244659662, green: 0.8163716197, blue: 0.9365672469, alpha: 1)
let level1:UIColor = #colorLiteral(red: 0.4857189059, green: 0.8915937543, blue: 0.9125001431, alpha: 1)
let level2:UIColor = #colorLiteral(red: 0.3039706051, green: 0.9125819802, blue: 0.7393057942, alpha: 1)
let level3:UIColor = #colorLiteral(red: 0.01003919728, green: 0.9901310802, blue: 0.04647519439, alpha: 1)
let level4:UIColor = #colorLiteral(red: 0.7198415399, green: 0.9990599751, blue: 0, alpha: 1)
let level5:UIColor = #colorLiteral(red: 0.9779006839, green: 0.9837408662, blue: 0.005338181742, alpha: 1)
let level6:UIColor = #colorLiteral(red: 0.9686422944, green: 0.7871474624, blue: 0, alpha: 1)
let level7:UIColor = #colorLiteral(red: 0.9603640437, green: 0.2288044393, blue: 0.02238469757, alpha: 1)

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var goView: UIView!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var severeLabel: UILabel!
    @IBOutlet weak var lightLabel: UILabel!
    
    @IBOutlet weak var lastHourLabel: UILabel!
    
    var contractions = [Contraction]()
    
    let moc = CoreDataManager().managedObjectContext
    
    let widgetDefaults = UserDefaults(suiteName: "group.com.gergusa04.Contraction-ator")!

   // let commandCenter = MPRemoteCommandCenter.shared()
    
    lazy var frc: NSFetchedResultsController<Contraction> = {
        let request: NSFetchRequest<Contraction> = Contraction.fetchRequest()
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.moc, sectionNameKeyPath: nil, cacheName: nil)
        return controller
    }()
    

    
    let brain = TimerBrain.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        frc.delegate = self
        lightLabel.text = "1\nlight"
        severeLabel.text = "10\nsevere"

        //tableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        startButton.layer.cornerRadius = 10
        startButton.layer.masksToBounds = true
        timeLabel.layer.cornerRadius = 10
        timeLabel.layer.masksToBounds = true
        goView.layer.cornerRadius = 17
        goView.layer.masksToBounds = true
        self.tableView.tableFooterView = UIView()
        
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            print("Error fetching Contraction objects: \(error.localizedDescription)")
        }
        
        let sliderVal = UserDefaults.standard.float(forKey: "LastSliderValue")
        slider.setValue(sliderVal, animated: false)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintAdjustmentMode = .normal
        self.navigationController?.navigationBar.tintAdjustmentMode = .automatic
        goView.backgroundColor = .white
        averageInLastHour()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditSegue" {
            if let destination = segue.destination as? EditViewController,
                let indexPath = tableView.indexPathForSelectedRow {
                let contraction = frc.object(at: indexPath)
                //let contraction = contractions[indexPath.row]
                destination.contraction = contraction
                destination.moc = moc
            }
        }
        if segue.identifier == "ChartSegue" {
            if let destination = segue.destination as? DetailContractionViewController {
                destination.context = moc
            }

        }
    }
        
        

 
    
    @IBAction func chartTapped(_ sender: UIBarButtonItem) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        let viewController = storyboard.instantiateViewController(withIdentifier: "DetailContractionViewController") as! DetailContractionViewController
       // viewController.contraction = contraction
        viewController.context = moc
        navigationController?.show(viewController, sender: sender)  //present(viewController, animated: true) {
           // self.tableView.reloadData()
       // }
        
        

        
    }
    @IBAction func resetAllTapped(_ sender: UIBarButtonItem) {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Contraction> = NSFetchRequest(entityName: Contraction.EntityName)
        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        
        do {
            try moc.execute(batchDeleteRequest)
            
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            try frc.performFetch()
        } catch {
            print("Error fetching Contraction objects: \(error.localizedDescription)")
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        if brain.pauseTapped && brain.isTimerRunning {
            // Finished a Contraction & hitting Stop
            brain.babyTimer.invalidate()
            brain.isTimerRunning = false
            storeContraction()
        } else if brain.pauseTapped && !brain.isTimerRunning {
            // All other times Starting
            brain.resetTimer(label: timeLabel)
            setupAndStartTimer()
            UserDefaults.standard.set(Date(), forKey: "MarkedContraction")
        } else {
            // First time through
            setupAndStartTimer()
            brain.pauseTapped = true
        }
        
        adjustButton()
        
        print("isTimerRunning = \(brain.isTimerRunning)")
        print("seconds = \(brain.seconds)")
        if let contr = contractions.last {
            print("\(contr.duration)")
            print("\(String(describing: contr.dateHadStarted))")
        }
        if let contra = contractions.first {
            print("\(contra.duration)")
            print("\(String(describing: contra.dateHadStarted))")
        }
    }
    
    
    func setupAndStartTimer() {
        if !brain.isTimerRunning {
            brain.babyTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLabelAndCounter), userInfo: nil, repeats: true)
            brain.isTimerRunning = true
        }
    }
    
    func storeContraction() {
        let duration = TimeInterval(brain.seconds)
        
        let contraction = NSEntityDescription.insertNewObject(forEntityName: Contraction.EntityName, into: moc) as! Contraction
        //let contraction = Contraktion()
        contraction.duration = duration
        contraction.dateHadStarted = (Date() - duration)
        contraction.dateHadFinished = Date()
        contraction.dialation = Int(slider.value)
        
        if let objects = frc.fetchedObjects {
            let contrct = objects.first
            guard let dateHadStart = contrct?.dateHadStarted else { return }
            contraction.lastContractionStamp = dateHadStart
            //guard let dateHadFinish = contrct?.dateHadFinished else { return }
            contraction.timeSinceLast = (dateHadStart.timeIntervalSinceNow * -1) - (duration)
            let lastInterval = contraction.timeSinceLast
            contraction.averageTimeApart = avgApartLast3(including: lastInterval)
        }
        contraction.averageDuration = averageLast3(including: duration)
        
        let durationDouble = Double(duration)
        widgetDefaults.set(durationDouble, forKey: "WidgetLastDuration")
        widgetDefaults.synchronize()
        
        var kontractDictionary = widgetDefaults.dictionary(forKey: "ITEMS_KEY") ?? Dictionary()
        // if todoItems hasn't been set in user defaults, initialize todoDictionary to an empty dictionary using nil-coalescing operator (??)
        // let id = UUID().uuidString
        kontractDictionary = ["duration": contraction.duration,
                              "dateHadStarted": contraction.dateHadStarted ?? Date(),
                              "note": contraction.note ?? "",
                              "timeSinceLast": contraction.timeSinceLast,
                              //"intensity": contraction.intensity,
                              "dateHadFinished": contraction.dateHadFinished ?? Date(),
                              "averageTimeApart": contraction.averageTimeApart,
                              "averageDuration": contraction.averageDuration,
                              "lastContractionStamp": contraction.lastContractionStamp ?? Date()]
 
        // store NSData representation of todo item in dictionary with UUID as key
        widgetDefaults.set(kontractDictionary, forKey: "ITEMS_KEY")
        
        moc.saveChanges()
        averageInLastHour()
    }
    
    func adjustButton() {
        if brain.isTimerRunning {
            startButton.setTitle("STOP", for: .normal)
            startButton.backgroundColor = .red
            timeLabel.backgroundColor = .yellow
        } else {
            startButton.setTitle("START", for: .normal)
            startButton.backgroundColor = .blue
            timeLabel.backgroundColor = .clear
        }
    }
    
    @objc func updateLabelAndCounter() {
        brain.seconds += 1
        timeLabel.text = TimerBrain.shortTimeString(time: TimeInterval(brain.seconds))
        
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        let intensity = TimerBrain.convertIntensity(currentValue: currentValue)

        DispatchQueue.main.async {
            self.sliderLabel.text = "\(currentValue) \(intensity)"
        }
        let currentSliderVal = slider.value
        UserDefaults.standard.set(currentSliderVal, forKey: "LastSliderValue")
    }
    
    func badstoreContraction() {
        let contraction = Contraktion()
        
        let duration = TimeInterval(brain.seconds)
        contraction.duration = duration
        contraction.dateHadStarted = (Date() - duration)
        contraction.dateHadFinished = Date()
        
        if !contractions.isEmpty {
            let contrct = contractions.first
            guard let dateHadStart = contrct?.dateHadStarted else { return }
            contraction.lastContractionStamp = dateHadStart
            guard let dateHadFinish = contrct?.dateHadFinished else { return }
            contraction.timeSinceLast = (dateHadFinish.timeIntervalSinceNow * -1) - (duration)
            let lastInterval = contraction.timeSinceLast ?? 0.0
            contraction.averageTimeApart = avgApartLast3(including: lastInterval)
        }
        contraction.averageDuration = averageLast3(including: duration)
        contraction.UUID = NSUUID().uuidString
        let durationDouble = Double(duration)
        //        widgetDefaults.set(durationDouble, forKey: "WidgetLastDuration")
        //        widgetDefaults.synchronize()
        
        var kontractDictionary = widgetDefaults.dictionary(forKey: "ITEMS_KEY") ?? Dictionary()
        kontractDictionary[(contraction.UUID ?? "")] = Contraktion.contraktionToDict(contrak: contraction)

        widgetDefaults.set(kontractDictionary, forKey: "ITEMS_KEY")
        tableView.reloadData()
        
    }
    
}

extension ViewController {
    
    func averageInLastHour() {
       // let now = Date()
       // var averagingContractions: [Contraction] = []
        let keyDate = Date(timeIntervalSinceNow: -60 * 60 )
        guard let objects = frc.fetchedObjects else { return }
        if objects.count > 0 {

            let lastHourContractions = objects.filter({ $0.dateHadStarted! > keyDate })
            let lastHourAvgTimeApart = getAvgTimeApart(contractions: lastHourContractions)
            let lastHourAvgDuration = getAvgDuration(contractions: lastHourContractions)
            
            let lastHourReady = haveTheyBeenGoingOnForHour(contractions: lastHourContractions, duration: lastHourAvgDuration, apart: lastHourAvgTimeApart)
            goView.backgroundColor = (lastHourReady) ? .green : .red
            lastHourLabel.text = "Last hr: \(TimerBrain.shortTimeString(time: lastHourAvgTimeApart)) apart\nlasting \(TimerBrain.shortTimeString(time: lastHourAvgDuration)) seconds"
            
            print("lastHourAvgDuration \(lastHourAvgDuration)\n")
            print("lastHourAvgTimeApart \(lastHourAvgTimeApart)\n")
        }

                
        
    }
    
    func getAvgDuration(contractions: [Contraction]) -> Double {
        var time = 0.0
        for contrac in contractions {
            time += contrac.duration
        }
        let avg = (contractions.count > 0) ? time/Double(contractions.count) : 1.0
        
        return avg
    }
    
    func getAvgTimeApart(contractions: [Contraction]) -> Double {
        guard contractions.count >= 1 else { return 0.0 }
        let index = contractions.count - 1
        var newContractions = contractions
        newContractions.remove(at: index)
        var time = 0.0
        for contrac in newContractions {
            time += contrac.timeSinceLast
        }
        let avg = (newContractions.count > 0) ? time/Double(newContractions.count) : 1.0
        return avg
    }
    
    func haveTheyBeenGoingOnForHour(contractions: [Contraction], duration: Double, apart: Double) -> Bool {
        var isReady = false
        if contractions.count >= 11  && duration >= 60.0 && apart <= 300.0 {
            isReady = true
        }
        return isReady
    }
    
    func averageLast3(including duration: Double) -> Double {
        var avg = 0.0
        if let objects = frc.fetchedObjects {
            switch objects.count {
            case nil:
                avg = duration
            case 0:
                avg = duration
            case 1:
                let c1 = objects[0].duration
                avg = (c1 + duration) / 2.0
            case 2:
                let c1 = objects[0].duration
                let c2 = objects[1].duration
                avg = (c1 + c2 + duration) / 3.0
            case 3:
                let c1 = objects[0].duration
                let c2 = objects[1].duration
                let c3 = objects[2].duration
                avg = (c1 + c2 + c3 + duration) / 4.0
            case 4:
                let c1 = objects[0].duration
                let c2 = objects[1].duration
                let c3 = objects[2].duration
                let c4 = objects[3].duration
                avg = (c1 + c2 + c3 + c4 + duration) / 5.0
            default:
                let c1 = objects[0].duration
                let c2 = objects[1].duration
                let c3 = objects[2].duration
                let c4 = objects[3].duration
                let c5 = objects[4].duration
                avg = (c1 + c2 + c3 + c4 + c5 + duration) / 6.0
            }
        }
        return avg
    }
    
    func avgApartLast3(including lastTime: Double) -> Double {
        var avg = 0.0
        if let objects = frc.fetchedObjects {
            switch objects.count {
            case nil:
                avg = lastTime
            case 0:
                avg = lastTime
            case 1:
                let c1 = objects[0].timeSinceLast
                avg = (c1 + lastTime) / 2.0
            case 2:
                let c1 = objects[0].timeSinceLast
                let c2 = objects[1].timeSinceLast
                avg = (c1 + c2 + lastTime) / 3.0
            case 3:
                let c1 = objects[0].timeSinceLast
                let c2 = objects[1].timeSinceLast
                let c3 = objects[2].timeSinceLast
                avg = (c1 + c2 + c3 + lastTime) / 4.0
            case 4:
                let c1 = objects[0].timeSinceLast
                let c2 = objects[1].timeSinceLast
                let c3 = objects[2].timeSinceLast
                let c4 = objects[3].timeSinceLast
                avg = (c1 + c2 + c3 + c4 + lastTime) / 5.0
            default:
                let c1 = objects[0].timeSinceLast
                let c2 = objects[1].timeSinceLast
                let c3 = objects[2].timeSinceLast
                let c4 = objects[3].timeSinceLast
                let c5 = objects[4].timeSinceLast
                avg = (c1 + c2 + c3 + c4 + c5 + lastTime) / 6.0
            }
        }
        return avg
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return frc.sections?.count ?? 0
       // return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = frc.sections?[section] else {
            return 0
        }
        return section.numberOfObjects
        //return contractions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContractionTableViewCell", for: indexPath) as! ContractionTableViewCell
        
        let contraction = frc.object(at: indexPath)
       // let contraction = contractions[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        guard let contractionDate = contraction.dateHadStarted else { return UITableViewCell() }
        
        let dayHad = dateFormatter.string(from: contractionDate)
        
        cell.dateHadLabel.text = dayHad
        let length = TimerBrain.shortTimeString(time: contraction.duration)
        cell.lengthLabel.text = "\(length)"

        let previous = TimerBrain.timeString(time: contraction.timeSinceLast)
        cell.timeSinceLastLabel.text = "\(previous)"
        let avgCntrct = TimerBrain.shortTimeString(time: contraction.averageDuration)
        cell.avgContractionLabel.text = "\(avgCntrct)"
        var avgInterval = TimerBrain.timeString(time: contraction.averageTimeApart)
        let parts = avgInterval.components(separatedBy: ":")
        if parts.first == "00" {
            avgInterval.remove(at: avgInterval.startIndex)
            avgInterval.remove(at: avgInterval.startIndex)
            avgInterval.remove(at: avgInterval.startIndex)
        }
        cell.avgApartLabel.text = "\(avgInterval)"
        let intenseWord = TimerBrain.convertIntensity(currentValue: contraction.dialation)
        cell.dialationLabel.text = "\(contraction.dialation) (\(intenseWord))"
        
        if contraction.note != nil && contraction.note != "" {
            cell.noteLabel.alpha = 1.0
        } else {
            cell.noteLabel.alpha = 0.0
        }
        

        

        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        // Whenever a user swipes a cell, we will show two options.
        // A option to mark a task completed.
//        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
//            self.editContraction(indexPath)
//        })
        
        // And a option to delete a task.
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            self.deleteTaskIn(indexPath)
        })
        
        return [deleteAction]
    }
    
    func editContraction(_ indexPath : IndexPath) {
        let contraction = self.frc.object(at: indexPath)
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        let viewController = storyboard.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
        viewController.contraction = contraction
        viewController.moc = moc
        self.present(viewController, animated: true) {
            self.tableView.reloadData()
        }
        
        // Update the attribute
        //task.completed = true
        
        do {
            // And try to persist the change. If successfull
            // the fetched results controller will react and call the method
            // to reload the table view.
            try self.moc.save()
        } catch {
            print("error happened while saving")
        }
    }
    
    func deleteTaskIn(_ indexPath : IndexPath) {
        let contraction = self.frc.object(at: indexPath)
        
        let deleteAlert = UIAlertController(title: "Delete contraction?", message: "This contraction will be deleted.", preferredStyle: UIAlertControllerStyle.alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle Ok logic here")
            // Then we use the managed object context and delete that object.
            self.moc.delete(contraction)
            
            do {
                // And try to persist the change. If successfull
                // the fetched results controller will react and call the method
                // to reload the table view.
                try self.moc.save()
            } catch {}
            
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(deleteAlert, animated: true, completion: nil)
        
        
 
    }
    
    func setbackgroundForDuration(time: Double) -> UIColor {
        switch time {
        case 0.0...30.0: return level0
            case 0.0...15.0: return level0
            case 15.1...30.0: return level1
            case 30.1...45.0: return level2
            case 45.1...50.0: return level3
            case 50.1...60.0: return level4
            case 60.1...70.0: return level5
            case 70.1...80.0: return level6
            case 80.0...900.0: return level7
        default: return UIColor.white
        }
    }
    
    func setbackgroundForTimeApart(time: Double)  -> UIColor {
       return UIColor.red
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contraction = frc.object(at: indexPath)
        //let contraction = contractions[indexPath.row]
    }
    
}

extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        if let objects = frc.fetchedObjects {
            contractions = objects
        }
        tableView.reloadData()
    }
}


// if todoItems hasn't been set in user defaults, initialize todoDictionary to an empty dictionary using nil-coalescing operator (??)
// let id = UUID().uuidString
/*["duration": contraction.duration ?? 0.0,
 "dateHadStarted": contraction.dateHadStarted ?? Date(),
 "note": contraction.note ?? "",
 "timeSinceLast": contraction.timeSinceLast ?? 0.0,
 "intensity": contraction.intensity ?? 1,
 "dateHadFinished": contraction.dateHadFinished ?? Date(),
 "averageTimeApart": contraction.averageTimeApart ?? 0.0,
 "averageDuration": contraction.averageDuration ?? 0.0,
 "lastContractionStamp": contraction.lastContractionStamp ?? Date()]
 */

/*
 var duration: Double?
 var dateHadStarted: Date?
 var note: String?
 var timeSinceLast: Double?
 var intensity: Int64?
 var dateHadFinished: Date?
 var averageTimeApart: Double?
 var averageDuration: Double?
 var lastContractionStamp: Date?
 var UUID: String? //NSUUID().
 */

//    func allItems() -> [Contraktion] {
//        let todoDictionary = widgetDefaults.dictionary(forKey: "ITEMS_KEY") ?? [:]
//        if !todoDictionary.isEmpty {
//        let items = Array(todoDictionary.values)
//        return items.map({
//            let item = $0 as! [String: Any]
//            return Contraktion(dict: item)
//        }).sorted(by: { (left, right) -> Bool in
//            return left.dateHadStarted!.compare(right.dateHadStarted!) == .orderedAscending
//        })
//        } else {
//            return []
//        }
//
//    }

