//
//  SettingsViewController.swift
//  Umbrella
//
//  Created by User on 9/16/17.
//  Copyright © 2017 louis.sun. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()  
    }

  
    @IBAction func setButtonPressed(_ sender: Any) {
        guard let zipString = textField.text else {return}
        guard Int(zipString) != nil else {
            //zip code contains characters other than numbers
            self.sendSimpleAlert(title: "Error", message: "Zip code not valid. Please enter numbers")
            return
        }
        guard zipString.characters.count == 5 else {
            //zip code too short or too long
            self.sendSimpleAlert(title: "Error", message: "Zip code not the right length.")
            return
        }
        //add zip to userdefaults
        UserDefaults.standard.set(zipString, forKey: "zipString")
        ZipSingleton.sharedZip.zip = zipString
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getRepositories"), object: nil)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func sendSimpleAlert(title:String,message:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
