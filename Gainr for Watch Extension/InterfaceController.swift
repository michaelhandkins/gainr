//
//  InterfaceController.swift
//  Gainr for Watch Extension
//
//  Created by Michael Handkins on 11/15/20.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController {
    
    //The session facilitates the flow of data between the iPhone and Apple Watch
    var session = WCSession.default

    @IBOutlet weak var caloriesRemaining: WKInterfaceLabel!
    
    let defaults = UserDefaults.standard
    
    @IBAction func resetPressed() {
        self.session.sendMessage(["watchResetPressed" : true], replyHandler: nil, errorHandler: nil)
    }
    
    
    override func awake(withContext context: Any?) {
        //Set the calories remaining label to show the calories remaining according to the last update from the phone, which is stored using User Defaults
        caloriesRemaining.setText(defaults.string(forKey: "caloriesRemainingFromPhone"))
        
        //Add an observer of the notification that gets posted whenever data is received from the phone
        NotificationCenter.default.addObserver(self, selector: #selector(receivedDataFromPhone(info:)), name: NSNotification.Name(rawValue: "receivedPhoneData"), object: nil)
    }
    
    @objc func receivedDataFromPhone(info: NSNotification) {
        let message = info.userInfo
        let caloriesRemainingString = String(message!["dataForWatch"] as! Int)
        
        //Update the calories remaining text on the main thread along with the text color if necessary, then save the new calories remaining data in User Defaults
        DispatchQueue.main.async {
            self.caloriesRemaining.setText(caloriesRemainingString)
            if (message!["dataForWatch"] as! Int) < 0 {
                self.caloriesRemaining.setTextColor(UIColor.red)
            } else {
                self.caloriesRemaining.setTextColor(UIColor.white)
            }
            self.defaults.setValue(caloriesRemainingString, forKey: "caloriesRemainingFromPhone")
        }
        
    }
    
    override func willActivate() {
        //Inform the phone that the watch just moved into the foreground and needs updated calories remaining data
        self.session.sendMessage(["watchAwakened" : true], replyHandler: nil, errorHandler: nil)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }

}
