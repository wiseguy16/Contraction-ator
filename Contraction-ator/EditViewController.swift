//
//  EditViewController.swift
//  Contraction-ator
//
//  Created by Greg Weiss on 3/31/18.
//  Copyright © 2018 Greg Weiss. All rights reserved.
//

import UIKit
import CoreData

class EditViewController: UIViewController  {
    var contraction: Contraction!
    var moc: NSManagedObjectContext!
    
    @IBOutlet weak var durationTextField: UITextField!
    
    @IBOutlet weak var timeApartTextFiled: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var noteTextView: UITextView!
    
    @IBOutlet weak var intesityLabel: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var intensitySlider: UISlider!
    
    @IBOutlet weak var dialationSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        noteTextView.delegate = self
        durationTextField.delegate = self
        timeApartTextFiled.delegate = self
        
        saveButton.layer.cornerRadius =  10.0
        saveButton.layer.borderColor = UIColor.gray.cgColor
        saveButton.layer.borderWidth = 0.54
        saveButton.layer.masksToBounds = true
        
        setupView()
        

        // Do any additional setup after loading the view.
    }
    @IBAction func saveTapped(_ sender: UIButton) {
        moc.saveChanges()
        UIView.animate(withDuration: 0.3, animations: {
            self.saveButton.backgroundColor = .yellow
            self.saveButton.titleLabel?.text = "  ✓"
        }) { (true) in
            UIView.animate(withDuration: 0.3, animations: {
                self.saveButton.backgroundColor = .white
                self.saveButton.titleLabel?.text = "  ✓"
            }) { (true) in
                UIView.animate(withDuration: 0.3, animations: {
                    self.saveButton.titleLabel?.text = "SAVE"
                })
            }
            
        }
    }
    

    @IBAction func cancelTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dateTimeChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        contraction.dateHadStarted = datePicker.date
    }
    
    
    @IBAction func intesityChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        let intensity = TimerBrain.convertIntensity(currentValue: currentValue)
        
        DispatchQueue.main.async {
            self.intesityLabel.text = "Intensity: \(currentValue)"
        }
        let currentSliderVal = intensitySlider.value
        contraction.dialation = Int(intensitySlider.value)
    }
    
    
    
    func setupView() {
        if let note = contraction.note {
           noteTextView.text = note
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        guard let contractionDate = contraction.dateHadStarted else { return }
        
        let dayHad = dateFormatter.string(from: contractionDate)
        datePicker.setDate(contractionDate, animated: true)
        //cell.dateHadLabel.text = dayHad
        let length = TimerBrain.shortTimeString(time: contraction.duration)
        durationTextField.text = "\(length)"
        
        let previous = TimerBrain.timeString(time: contraction.timeSinceLast)
        timeApartTextFiled.text = "\(previous)"
        let avgCntrct = TimerBrain.shortTimeString(time: contraction.averageDuration)
        //cell.avgContractionLabel.text = "\(avgCntrct)"
        var avgInterval = TimerBrain.timeString(time: contraction.averageTimeApart)
        let parts = avgInterval.components(separatedBy: ":")
        if parts.first == "00" {
            avgInterval.remove(at: avgInterval.startIndex)
            avgInterval.remove(at: avgInterval.startIndex)
            avgInterval.remove(at: avgInterval.startIndex)
        }
        //cell.avgApartLabel.text = "\(avgInterval)"
        let intenseWord = TimerBrain.convertIntensity(currentValue: contraction.dialation)
        //cell.dialationLabel.text = "\(contraction.dialation) (\(intenseWord))"
        let sliderVal = Float(contraction.dialation)
        intensitySlider.setValue(sliderVal, animated: false)
        self.intesityLabel.text = "Intensity: \(contraction.dialation)"
    
    }

   

}
extension EditViewController {
    
    func convertTimeDisplayToDouble(_ display: String) -> Double {
        let componets = display.components(separatedBy: ":")
        switch componets.count {
        case 0:
            return 0.0
        case 1:
            guard let seconds = Double(componets[0]) else { return 0.0 }
            return seconds
        case 2:
            guard let minutes = Double(componets[0]) else { return 0.0 }
            guard let seconds = Double(componets[1]) else { return 0.0 }
            let timevalue = minutes * 60 + seconds
            return timevalue
        case 3:
            guard let hours = Double(componets[0]) else { return 0.0 }
            guard let minutes = Double(componets[1]) else { return 0.0 }
            guard let seconds = Double(componets[2]) else { return 0.0 }
            let timevalue = (hours * 3600) + (minutes * 60) + seconds
            return timevalue
        default:
            return 0.0
        }
        
    }
    
}

extension EditViewController: UITextFieldDelegate, UITextViewDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {

        if textField == durationTextField {
            guard let duration = textField.text else { return }
            let timeAsDouble = convertTimeDisplayToDouble(duration)
            debugPrint("durationTextField \(timeAsDouble)")
            contraction.duration = timeAsDouble
        }
        if textField == timeApartTextFiled {
            guard let timeSinceLast = textField.text else { return }
            let timeAsDouble = convertTimeDisplayToDouble(timeSinceLast)
            debugPrint("timeApartTextFiled \(timeAsDouble)")
            contraction.timeSinceLast = timeAsDouble
        }
        debugPrint("textFieldDidEndEditing \(textField.text ?? "nothing here")")
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == noteTextView {
            contraction.note = textView.text
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == noteTextView {
            contraction.note = textField.text
        }
        if textField == durationTextField {
            guard let duration = textField.text else { return false }
            let timeAsDouble = convertTimeDisplayToDouble(duration)
            debugPrint("durationTextField \(timeAsDouble)")
            contraction.duration = timeAsDouble
        }
        if textField == timeApartTextFiled {
            guard let timeSinceLast = textField.text else { return false  }
            let timeAsDouble = convertTimeDisplayToDouble(timeSinceLast)
            debugPrint("timeApartTextFiled \(timeAsDouble)")
            contraction.timeSinceLast = timeAsDouble
        }
        debugPrint("textFieldShouldReturn \(textField.text ?? "nothing here")")

        self.view.endEditing(true)
        return true
    }
}

