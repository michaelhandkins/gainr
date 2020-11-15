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
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goalField.delegate = self
        
        if let safeGoal = defaults.string(forKey: "userGoal") {
            goalField.text = safeGoal
        } else {
            goalField.placeholder = "2000"
        }
        
        if goalField.text != "" {
            caloriesRemaining.text = goalField.text
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == goalField {
            caloriesRemaining.text = textField.text
            defaults.setValue(textField.text, forKey: "userGoal")
        }
    }


}

