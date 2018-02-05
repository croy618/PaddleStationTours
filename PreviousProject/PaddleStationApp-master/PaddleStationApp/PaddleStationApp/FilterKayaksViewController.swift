//
//  FilterKayaksViewController.swift
//  PaddleStationApp
//
//  Created by Jamie Mills on 2017-12-04.
//  Copyright © 2017 PaddleStation. All rights reserved.
//

import UIKit

class FilterKayaksViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var numOfPeopleTextField: UITextField!
    
    var typeOptions = ["Kayak", "Large Raft", "Small Raft"]
    
    @IBAction func dateTextEditing(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.date
        
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControlEvents.valueChanged)
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateTextField.text = dateFormatter.string(from: sender.date)
    }
    
    
    @IBAction func timePickerTextEditing(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.time
        
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.timePickerValueChanged), for: UIControlEvents.valueChanged)
    }
    
    @objc func timePickerValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.none
        dateFormatter.timeStyle = DateFormatter.Style.short
        timeTextField.text = dateFormatter.string(from: sender.date)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return typeOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return typeOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typeTextField.text = typeOptions[row]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var pickerView = UIPickerView()
        pickerView.delegate = self
        
        typeTextField.inputView = pickerView
        numOfPeopleTextField.keyboardType = UIKeyboardType.numberPad
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let date = dateTextField.text ?? ""
        let time = timeTextField.text ?? ""
        let item = typeTextField.text ?? ""
        let numberOfPeople = numOfPeopleTextField.text ?? ""
        
        //Fix the input type for checkfront request date
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MMM dd, yyyy"
        let showDate = inputFormatter.date(from: date)
        inputFormatter.dateFormat = "yyyyMMdd"
        let dateString = inputFormatter.string(from: showDate!)
        
         //Fix the input type for checkfront request time
        inputFormatter.dateFormat = "h:mm a"
        let showTime = inputFormatter.date(from: time)
        inputFormatter.dateFormat = "HH:mm"
        let timeString = inputFormatter.string(from: showTime!)
       
        
        
        let booking = Booking(date: dateString, time: timeString, item: item, numOfPeople: numberOfPeople)
        
        if let destinationViewController = segue.destination as? FindKayaksViewController {
            
            destinationViewController.bookingDetails = booking
            
            let checkFrontRequest = CheckFrontRequest()
            
            checkFrontRequest.getAvailability(date: booking.date, item: booking.itemID, numOfPeople: booking.numOfPeople, startTime: booking.startTime) {(availabile) in destinationViewController.setAvailability(availabile)}
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
