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
import Orchextra

protocol SettingsOutput {
    func orxCredentialsChanged(apikey: String, apiSecret: String)
}

class SettingsVC: UIViewController, KeyboardAdaptable {

    @IBOutlet weak var closeButton: ButtonRounded!
    @IBOutlet weak var apiKeyLabel: TextfieldRounded!
    @IBOutlet weak var apiSecretLabel: TextfieldRounded!
    @IBOutlet weak var typeCustomFieldSwitch: UISwitch!
    @IBOutlet weak var levelCustomFieldPicker: UIPickerView!
    @IBOutlet weak var levelCustomFieldView: UIView!
    @IBOutlet weak var customFieldLevelLabel: UILabel!
    
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    var settingsOutput: SettingsOutput?
    let ocm = OCM.shared
    let session = Session.shared
    let appController = AppController.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        self.apiKeyLabel.text = AppController.shared.orchextraApiKey
        self.apiSecretLabel.text = AppController.shared.orchextraApiSecret
        self.view.addGestureRecognizer(tapGesture)
        
        let pickerTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapCustomFieldLevelView(_:)))
        self.levelCustomFieldView.addGestureRecognizer(pickerTapGesture)
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
    
    @objc func tapCustomFieldLevelView(_ sender: Any) {
        self.showPicker()
    }
    
    func hideKeyboardFromTextFields() {
        self.apiKeyLabel.resignFirstResponder()
        self.apiSecretLabel.resignFirstResponder()
        self.levelCustomFieldPicker.isHidden = true
    }
    
    @IBAction func startTapped(_ sender: Any) {
        guard let apikey = self.apiKeyLabel.text,
            let apisecret = self.apiSecretLabel.text else {
                    return
        }
        
        self.hideKeyboardFromTextFields()

        if apikey.isEmpty || apisecret.isEmpty
            || apikey.count == 0
            || apisecret.count == 0 {
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
                        var customFields = [ORCCustomField]()
                        let user = Orchextra.sharedInstance().currentUser()
                        user.crmID = "carlos.vicente@gigigo.com"
                        Orchextra.sharedInstance().bindUser(user)
                        self.session.saveORX(apikey: self.appController.orchextraApiKey,
                                             apisecret: self.appController.orchextraApiSecret)
                        let typeCustomFieldValue = self.typeCustomFieldSwitch.isOn ? "B" : "A"
                        if let customFieldType = ORCCustomField(key: "type", label: "type", type: .string, value: typeCustomFieldValue) {
                            customFields.append(customFieldType)
                        }
                        if let levelCustomFieldValue: String = self.customFieldLevelLabel.text,
                            levelCustomFieldValue.count > 0 {
                            if let customFieldLevel = ORCCustomField(key: "level", label: "level", type: .string, value: levelCustomFieldValue) {
                                customFields.append(customFieldLevel)
                            }
                        }
                        Orchextra.sharedInstance().setCustomFields(customFields)
                        Orchextra.sharedInstance().commitConfiguration({ success, error in
                            if !success {
                                LogWarn(error.localizedDescription)
                            }
                        })
                        self.settingsOutput?.orxCredentialsChanged(apikey: apikey, apiSecret: apisecret)
                        
                        
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
    
    func showPicker() {
        let pickerHidden = self.levelCustomFieldPicker.isHidden
        self.levelCustomFieldPicker.isHidden = !pickerHidden
    }
}

extension SettingsVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0: return "Gold"
        case 1: return "Bronze"
        case 2: return "Silver"
        default: return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0: self.customFieldLevelLabel.text = "Gold"
        case 1: self.customFieldLevelLabel.text = "Bronze"
        case 2: self.customFieldLevelLabel.text = "Silver"
        default: self.customFieldLevelLabel.text = nil
        }
    }
}
