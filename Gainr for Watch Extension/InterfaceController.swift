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
    
    var session = WCSession.default

    @IBOutlet weak var caloriesRemaining: WKInterfaceLabel!
    
    let defaults = UserDefaults.standard
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        caloriesRemaining.setText(defaults.string(forKey: "caloriesRemainingFromPhone"))
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedDataFromPhone(info:)), name: NSNotification.Name(rawValue: "receivedPhoneData"), object: nil)
    }
    
    @objc func receivedDataFromPhone(info: NSNotification) {
        let message = info.userInfo
        let caloriesRemainingString = String(message!["dataForWatch"] as! Int)
        
        DispatchQueue.main.async {
            self.caloriesRemaining.setText(caloriesRemainingString)
            self.defaults.setValue(caloriesRemainingString, forKey: "caloriesRemainingFromPhone")
        }
        
    }
    
    override func willActivate() {
        self.session.sendMessage(["watchAwakened" : true], replyHandler: nil, errorHandler: nil)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }

}
