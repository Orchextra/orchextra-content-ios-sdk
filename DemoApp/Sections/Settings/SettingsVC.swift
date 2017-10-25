//
//  SettingsVC.swift
//  OCM
//
//  Created by Judith Medina on 25/10/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

protocol SettingOutput {
    func orxCredentialesHasChanged(apikey: String, apiSecret: String)
}

class SettingsVC: UIViewController, KeyboardAdaptable {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var apiKeyLabel: UITextField!
    @IBOutlet weak var apiSecretLabel: UITextField!
    
    var settingOutput: SettingOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.apiKeyLabel.text = AppController.shared.orchextraApiKey
        self.apiSecretLabel.text = AppController.shared.orchextraApiSecret
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopKeyboard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func startTapped(_ sender: Any) {
        
        guard let apikey = self.apiKeyLabel.text,
            let apisecret = self.apiSecretLabel.text else {
                    return
        }
        self.apiKeyLabel.resignFirstResponder()
        self.apiSecretLabel.resignFirstResponder()
        self.settingOutput?.orxCredentialesHasChanged(apikey: apikey, apiSecret: apisecret)
    }
    

}
