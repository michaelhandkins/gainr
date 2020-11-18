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
    
    //The session facilitates the flow of data between the iPhone and Apple Watch
    let session = WCSession.default

    var userEnteredCalories = "0"
    
    @IBOutlet weak var calorieField: WKInterfaceTextField!
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
    }
    
    //This function allows us access to the string that was just entered by the user on the textfield.
    @IBAction func textFieldAction(_ value: NSString?) {
        if value != nil {
            userEnteredCalories = value! as String
            print(userEnteredCalories)
        }
    }
    
    @IBAction func submitPressed() {
        //Let the phone know that the user just consumed more calories so that the calories remaining can be updated on the phone and then sent back to the watch's main interface as well
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
