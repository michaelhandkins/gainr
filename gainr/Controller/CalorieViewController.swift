//
//  ViewController.swift
//  gainr
//
//  Created by Michael Handkins on 11/15/20.
//

import UIKit
import WatchConnectivity

class CalorieViewController: UIViewController, UITextFieldDelegate {
    
    
    //The session facilitates the flow of data between the iPhone and Apple Watch
    let session = WCSession.default

    @IBOutlet weak var goalField: UITextField!
    @IBOutlet weak var caloriesRemaining: UILabel!
    @IBOutlet weak var caloriesConsumed: UITextField!
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        allCalories = [0]
        defaults.setValue(allCalories, forKey: "caloriesEaten")
        caloriesRemaining.text = String(userGoal)
        setFontColor()
        sendDataToWatch()
    }
    
    let defaults = UserDefaults.standard
    
    var allCalories: [Int] = [0]
    var totalConsumed: Int {
        allCalories.reduce(0, +)
    }
    var userGoal: Int {
        if let userEnteredGoal = defaults.string(forKey: "userGoal") {
            return Int(userEnteredGoal) ?? 2000
        } else {
            return 2000
        }
    }
    
    var caloriesRemainingValue: Int {
        userGoal - totalConsumed
    }
    
    func setFontColor() {
        if self.caloriesRemainingValue < 0 {
            caloriesRemaining.textColor = UIColor.red
        } else {
            caloriesRemaining.textColor = UIColor.systemIndigo
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addDoneButtonOnKeyboard()
        goalField.delegate = self
        caloriesConsumed.delegate = self
        
        if let safeGoal = defaults.string(forKey: "userGoal") {
            goalField.text = safeGoal
        } else {
            goalField.placeholder = "Enter Goal"
        }
        
        if let safeAllCalories = defaults.array(forKey: "caloriesEaten") {
            allCalories = safeAllCalories as! [Int]
        }
        caloriesRemaining.text = String(caloriesRemainingValue)
        
        //Send data to watch
        sendDataToWatch()
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedDataFromWatch), name: NSNotification.Name(rawValue: "receivedWatchData"), object: nil)
        
    }
    
    @objc func receivedDataFromWatch(info: NSNotification) {
        print("notification observed")
        let message = info.userInfo
        if let caloriesFromWatch = message?["caloriesFromWatch"] {
            let caloriesToDeduct = Int(caloriesFromWatch as! String)!
        
            //Perform the following changes on the main thread
            DispatchQueue.main.async {
                self.allCalories.append(caloriesToDeduct)
                self.defaults.setValue(self.allCalories, forKey: "caloriesEaten")
                self.caloriesRemaining.text = String(self.caloriesRemainingValue)
                //Send data to watch
                self.sendDataToWatch()
            }
        }
        
        if (message?["watchAwakened"]) != nil {
            //When the watch is awakened, make sure it gets the current info from the phone
            sendDataToWatch()
        }
        
        if (message?["watchResetPressed"]) != nil {
            DispatchQueue.main.async {
                self.allCalories = [0]
                self.defaults.setValue(self.allCalories, forKey: "caloriesEaten")
                self.caloriesRemaining.text = String(self.userGoal)
                self.setFontColor()
                self.sendDataToWatch()
            }
        }
    }
    
    func sendDataToWatch() {
        //Make sure that the watch app is downloaded and that the watch paired with the phone, then send data
        if self.session.isPaired == true && self.session.isWatchAppInstalled {
            self.session.sendMessage(["dataForWatch" : self.caloriesRemainingValue], replyHandler: nil, errorHandler: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setFontColor()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == caloriesConsumed {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        } else {
            //If the goalField is the field being edited, don't check to see if the keyboard will show or hide
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == goalField {
            if textField.text != "" {
                //Use User Defaults to save the user's calorie consumption goal
                defaults.setValue(textField.text, forKey: "userGoal")
            } else {
                //If they left the textfield blank, use their most recently entered goal or the default of 2000
                textField.text = String(userGoal)
            }
            //Regardless, set the text field's text to display their current goal...
            textField.text = defaults.string(forKey: "userGoal")
            //...then update the calories remaining label to reflect the calories remaining in light of the user's new goal
            caloriesRemaining.text = String(caloriesRemainingValue)
            //Send the updated data to the watch
            sendDataToWatch()
        } else if textField == caloriesConsumed {
            if textField.text != "" {
                //Add the new value to the list of calories consumed by the user, then store that list in User Defaults
                allCalories.append(Int(textField.text!)!)
                defaults.setValue(allCalories, forKey: "caloriesEaten")
                caloriesRemaining.text = String(caloriesRemainingValue)
                textField.text = ""
                //Send updated data to watch
                sendDataToWatch()
            }
        }
        setFontColor()
    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        goalField.inputAccessoryView = doneToolbar
        caloriesConsumed.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        goalField.resignFirstResponder()
        caloriesConsumed.resignFirstResponder()
    }

}

