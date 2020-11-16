//
//  AddCaloriesController.swift
//  Gainr for Watch Extension
//
//  Created by Michael Handkins on 11/15/20.
//

import Foundation
import WatchConnectivity
import WatchKit

class AddCaloriesController: WKInterfaceController {

    var userEnteredCalories = "0"
    
    @IBOutlet weak var calorieField: WKInterfaceTextField!
    
    let session = WCSession.default
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
    }
    
    @IBAction func textFieldAction(_ value: NSString?) {
        if value != nil {
            userEnteredCalories = value! as String
            print(userEnteredCalories)
        }
    }
    
    @IBAction func submitPressed() {
        self.session.sendMessage(["caloriesFromWatch" : self.userEnteredCalories], replyHandler: nil, errorHandler: nil)
        print("Message sent to phone")
        
        DispatchQueue.main.async {
            self.dismiss()
        }
    }
    
    
    override func willActivate() {
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    
}
