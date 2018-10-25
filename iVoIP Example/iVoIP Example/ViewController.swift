//
//  ViewController.swift
//  iVoIP Example
//
//  Created by Rajesh Thangaraj on 04/10/18.
//  Copyright © 2018 Rajesh Thangaraj. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    
    let appdelegate = (UIApplication.shared.delegate as! AppDelegate)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        welcomeLabel.text = "Welcome " + appdelegate.myName
        statusChanged()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "ConnectionStatusChanged"), object: nil, queue: nil) { (notification) in
            self.statusChanged()
        }
        callButton.setTitle("Call " + appdelegate.otherName, for: .normal)
    }
    
    func statusChanged() {
        switch appdelegate.status {
        case .connected:
            statusView.backgroundColor = .green
        case .connecting:
            statusView.backgroundColor = .yellow
        case .failed:
            statusView.backgroundColor = .red
        }
    }
    
    @IBAction func callButtonAction(_ sender: UIButton) {
        appdelegate.callOtherUser()
    }
    
}

