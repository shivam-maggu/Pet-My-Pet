//
//  LoginViewController.swift
//  Pet My Pet
//
//  Created by Shivam Maggu on 09/02/19.
//  Copyright © 2019 Shivam Maggu. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Alamofire
import Poi
import Pods_Pet_My_Pet

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var indicatorActivity: UIActivityIndicatorView!
    @IBOutlet weak var EyeButtonDefault: UIButton!
    @IBOutlet weak var checkButtonDefault: UIButton!
    var checkStatus: Bool = false
    var saveSuccessful: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        //Set delegates to control behaviour of textfield like controlling movement of cursor from username to password
        username.delegate = self
        password.delegate = self
        //Called to show and hide keyboard on login screen
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        //Called to dismiss keyboard when tapped anywhere on screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    //Dissmisses keyboard on screen tap
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    //Shows keyboard and moves login screen upwards to prevent login text fields from being covered by keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    //Hides keyboard and sets login screen back to original place
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    //Gives first responder control to password from username and sends cursor to password on pressing next key and closes keyboard on pressing return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Username tag = 1000 & password tag = 1001
        let nextTag = textField.tag + 1
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    //Sets status bar style to light
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //Resets login screen when view appears again and hides navigation bar on login screen
    override func viewWillAppear(_ animated: Bool) {
        username.text = ""
        password.text = ""
        EyeButtonDefault.isSelected = false
        password.isSecureTextEntry = true
        checkButtonDefault.isSelected = false
        checkStatus = false
        indicatorActivity.stopAnimating()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //Shows navigation bar again when login view is not on top of view stack
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //Takes credentials, set URL, send POST request to server, save token in keychain and move view to MainViewController on successful token save.
    //Shows error in case of failure to connect or get 404 response alert on entering wrong credentials
    func loginAlamo() {
        let parameters: [String : Any] = [
            "username" : "JohnDoe",//username.text!,
            "password" : "nineleaps"//password.text!
        ]
        let loginUrl = URL(string: "http://ec2-3-91-83-117.compute-1.amazonaws.com:3000/login")
        AlamofireWrapper().post(parameters: parameters, url: loginUrl!) { (tokenStringObject, messageStringObject, codeIntObject) in
            if codeIntObject == 200 {
                self.saveSuccessful = KeychainWrapper.standard.set(tokenStringObject!, forKey: "savedToken", withAccessibility: .afterFirstUnlock)
                if self.saveSuccessful {
                    //print("Session save status \(self.saveSuccessful)")
                    //print("message \(String(describing: messageStringObject))")
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyBoard.instantiateViewController(withIdentifier: "mainvc") as! MainViewController
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
            if codeIntObject == 404 {
                let title = "ERROR"
                let message = "Invalid Credentials"
                self.indicatorActivity.stopAnimating()
                self.alertBox(title: title, message: message)
            }
        }
    }
    
    //Checks various conditions before sending login request to see if username and password are entered properly
    @IBAction func loginBtn(_ sender: Any) {
        indicatorActivity.startAnimating()
        if username.text == "" && password.text == "" {
            let title = "ERROR"
            let message = "Credentials Missing"
            indicatorActivity.stopAnimating()
            alertBox(title: title, message: message)
        }
        else if username.text != "" && password.text == "" {
            let title = "ERROR"
            let message = "Password Missing"
            indicatorActivity.stopAnimating()
            alertBox(title: title, message: message)
        }
        else if username.text == "" && password.text != "" {
            let title = "ERROR"
            let message = "Username Missing"
            indicatorActivity.stopAnimating()
            alertBox(title: title, message: message)
        }
        else if checkStatus == false {
            let title = "ERROR"
            let message = "Please check terms and conditions."
            indicatorActivity.stopAnimating()
            alertBox(title: title, message: message)
        }
        else {
            loginAlamo()
        }
    }
    
    //Sets checkbox button to check or uncheck for normal or selected state
    @IBAction func checkBoxBtn(_ sender: UIButton) {
        if sender.isSelected == true {
            sender.setBackgroundImage(UIImage(named: "uncheck.png"), for: .normal)
            sender.isSelected = false
            checkStatus = false
        }
        else {
            sender.setBackgroundImage(UIImage(named: "check.png"), for: .selected)
            sender.isSelected = true
            checkStatus = true
        }
    }
    
    //Sets eye image to open or close and toggle secure password field
    @IBAction func toggleEye(_ sender: UIButton) {
        if sender.isSelected == true {
            sender.setImage(UIImage(named: "secure_text.png"), for: .normal)
            sender.isSelected = false
            password.isSecureTextEntry.toggle()
        }
        else {
            sender.setImage(UIImage(named: "insecure_text.png"), for: .selected)
            sender.isSelected = true
            password.isSecureTextEntry.toggle()
        }
    }
    
    //Displays alertbox; takes title and message as input to generate alert box
    public func alertBox(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    @IBAction func TermsButtonClick(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "t&cvc") as! TermsAndConditionsViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
