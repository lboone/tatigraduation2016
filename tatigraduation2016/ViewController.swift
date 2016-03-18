//
//  ViewController.swift
//  tatigraduation2016
//
//  Created by Lloyd Boone on 3/11/16.
//  Copyright © 2016 LAMB Apps. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        let kID = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID)
        if kID != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }/* else {
            print(NSUserDefaults.standardUserDefaults())
        }*/
    }

    @IBAction func fbBtnPressed(sender: UIButton!) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) { (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                //print("Facebook login failed. Error \(facebookError)")
                self.showErrorAlert("Facebook Login Failed!", msg: "\(facebookError)")
            } else if facebookResult.isCancelled {
                //print("Facebook login was cancelled.")
                self.showErrorAlert("Login Cancelled!", msg: "Facebool login was cancelled.")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                //print("Successfully logged in with facebook. \(accessToken)")
                
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { error, authData in
                    
                    if error != nil {
                        self.showErrorAlert("Login Failed!", msg: "\(error)")
                    } else {
                        //print("Logged In!\(authData)")
                        
                        let user = ["provider":authData.provider!, "blah":"this"]
                        DataService.ds.createFirebaseUser(authData.uid, user: user)
                        
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                        
                    }
                    
                })
                
            }

        }
        
    }
    
    @IBAction func attemptLogin(sender: UIButton!) {
        
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            
            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { error, authData in
                
                if error != nil {
                    
                    if error.code == STATUS_ACCOUNT_NONEXISTS {
                        DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { error, result in
                            
                            if error != nil {
                                self.showErrorAlert("Could not create account", msg: "Problem creating account.  Try again.")
                            } else {
                                DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { error, authData in
                                    //print("AuthDataUID: \(authData.uid) & AuthDataProvider: \(authData.provider)")
                                    NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                                    let user = ["provider":authData.provider!]
                                    DataService.ds.createFirebaseUser(authData.uid, user: user)
                                })
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                                
                            }
                            
                        })
                        
                    } else {
                        self.showErrorAlert("Could not login", msg: "Please check your username or password")
                    }
                } else {
                    NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
                
            })
            
        } else {
            showErrorAlert("Email and Password Required", msg: "You must provide a username and password.")
        }
        
        //print(NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID))
    }
    
    func showErrorAlert(title: String, msg: String){
        let alert = UIAlertController(title:title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

}

