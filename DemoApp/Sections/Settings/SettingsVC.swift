//
//  SettingsVC.swift
//  OCM
//
//  Created by Judith Medina on 25/10/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary
import OCMSDK

protocol SettingOutput {
    func orxCredentialesHasChanged(apikey: String, apiSecret: String)
}

class SettingsVC: UIViewController, KeyboardAdaptable {

    @IBOutlet weak var closeButton: ButtonRounded!
    @IBOutlet weak var apiKeyLabel: TextfieldRounded!
    @IBOutlet weak var apiSecretLabel: TextfieldRounded!
    
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    var settingOutput: SettingOutput?
    let ocm = OCM.shared
    let session = Session.shared
    let appController = AppController.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        self.apiKeyLabel.text = AppController.shared.orchextraApiKey
        self.apiSecretLabel.text = AppController.shared.orchextraApiSecret
        self.view.addGestureRecognizer(tapGesture)

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
    }
    

    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapView(_ sender: Any) {
        self.hideKeyboardFromTextFields()
    }
    
    func hideKeyboardFromTextFields() {
        self.apiKeyLabel.resignFirstResponder()
        self.apiSecretLabel.resignFirstResponder()
    }
    
    @IBAction func startTapped(_ sender: Any) {
        guard let apikey = self.apiKeyLabel.text,
            let apisecret = self.apiSecretLabel.text else {
                    return
        }
        
        self.hideKeyboardFromTextFields()

        if apikey.isEmpty || apisecret.isEmpty
            || apikey.characters.count == 0
            || apisecret.characters.count == 0 {
            let alert = Alert(
                title: "Credentials empty",
                message: "Apikey and Apisecret are mandatory to start orchextra.")
            alert.addCancelButton("Ok", usingAction: nil)
            alert.show()
        } else {
            self.startOrchextra(apikey: apikey, apisecret: apisecret)
        }
    }
    
    func startOrchextra(apikey: String, apisecret: String) {
            self.ocm.orchextraHost = self.appController.orchextraHost
            self.ocm.start(apiKey: apikey, apiSecret: apisecret) { result in
                    switch result {
                    case .success:
                        self.session.saveORX(apikey: self.appController.orchextraApiKey,
                                             apisecret: self.appController.orchextraApiSecret)
                        self.settingOutput?.orxCredentialesHasChanged(apikey: apikey, apiSecret: apisecret)
                    case .error:
                        self.showCredentialsErrorMessage()
                    }
        }
    }
    
    func showCredentialsErrorMessage() {
        let alert = Alert(
            title: "Credentials are not correct",
            message: "Apikey and Apisecret are invalid")
        alert.addCancelButton("Ok", usingAction: nil)
        alert.show()
    }
}
