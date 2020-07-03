//
//  ViewController.swift
//  payatease
//
//  Created by Andy Lin on 2020-06-15.
//  Copyright © 2020 Andy Lin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var errorMessage: UILabel!
    
    var name: String = ""
    var email : String = ""
    var balance : Float = 0
    var bill : [Bill] = []
    
    override func viewDidLoad() {
        
       
        
        //Hide keyboard after tapping on screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        view.addGestureRecognizer(tap)
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    //login to server and send get request
    @IBAction func sendRequest(_ sender: Any) {
        
        
        if username.text == "" || password.text == ""{
            errorMessage.text = "Please enter username and password"
        }
        
        else if let username = username.text, let pass = password.text{
            
            let request = HttpRequest(username: username, password: pass)
            request.getUser { [weak self] result in
                switch result{
                case .success(let user):
                    self?.name = user.username
                    self?.email = user.email
                    self?.balance = user.balance
                    self?.bill = user.bill
                    DispatchQueue.main.async {
                      self?.performSegue(withIdentifier: "showUser", sender: nil)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.errorMessage.text = "Wrong user name or password"
                    }
                    print(error)
                    return
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUser" {
            if let vc = segue.destination as? UserViewController {
                vc.username = self.name
                vc.password = self.password.text!
                vc.email = self.email
                vc.balance = self.balance
                vc.bill = self.bill
            }
        }
    }
    
    //dismissing keyboard
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

}

