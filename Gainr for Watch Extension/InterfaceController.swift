//
//  InterfaceController.swift
//  Gainr for Watch Extension
//
//  Created by Michael Handkins on 11/15/20.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

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
        
        caloriesRemaining.setText(caloriesRemainingString)
        defaults.setValue(caloriesRemainingString, forKey: "caloriesRemainingFromPhone")
    }
    
    override func willActivate() {
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }

}
