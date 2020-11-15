//
//  ViewController.swift
//  gainr
//
//  Created by Michael Handkins on 11/15/20.
//

import UIKit

class CalorieViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var goalField: UITextField!
    
    @IBOutlet weak var caloriesRemaining: UILabel!
    
    @IBOutlet weak var caloriesConsumed: UITextField!
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        allCalories = [0]
        defaults.setValue(allCalories, forKey: "caloriesEaten")
        caloriesRemaining.text = String(userGoal)
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addDoneButtonOnKeyboard()
        goalField.delegate = self
        caloriesConsumed.delegate = self
        
        if let safeGoal = defaults.string(forKey: "userGoal") {
            goalField.text = safeGoal
        } else {
            goalField.placeholder = "2000"
        }
        
        if let safeAllCalories = defaults.array(forKey: "caloriesEaten") {
            allCalories = safeAllCalories as! [Int]
        }
        caloriesRemaining.text = String(caloriesRemainingValue)
        
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
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == goalField {
            defaults.setValue(textField.text, forKey: "userGoal")
            caloriesRemaining.text = String(caloriesRemainingValue)
        } else if textField == caloriesConsumed {
            if textField.text != "" {
                allCalories.append(Int(textField.text!)!)
                defaults.setValue(allCalories, forKey: "caloriesEaten")
                caloriesRemaining.text = String(caloriesRemainingValue)
                textField.text = ""
            }
        }
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

