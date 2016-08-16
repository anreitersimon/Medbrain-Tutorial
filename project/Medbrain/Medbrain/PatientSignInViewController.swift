//
//  PatientSignInViewController.swift
//  Medbrain
//
//  Created by Simon Anreiter on 14/08/16.
//  Copyright © 2016 Simon Anreiter. All rights reserved.
//

import UIKit
import SMART

class PatientSignInViewController: UIViewController {
    typealias SignInCompletionHandler = (patient: Patient) -> Void

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    ///Will be called after the Sign-In successfully finished
    ///Note: user cannot leave screen without successfully signing in
    var completionHandler: SignInCompletionHandler?

    ///generate `LogInCredentials` from the information entered
    ///- returns: nil if the entered credentials are incomplete or invalid
    func generateCredentials() -> LogInCredentials? {
        //when sign-in is implemented properly this has to be adjusted

        //Always return the default credentials for the test-user
        return LogInCredentials.defaultCredentials
    }

    func showError(message message: String) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))

        presentViewController(alertController, animated: true, completion: nil)
    }

    @IBAction func submitButtonPressed(sender: AnyObject?) {
        //verify that the entered information is valid
        guard let credentials = generateCredentials() else {
            showError(message: "Entered Information is incomplete or invalid")
            return
        }

        //disable textFields so user cannot edit information while it is being submitted
        emailTextfield.userInteractionEnabled = false
        passwordTextfield.userInteractionEnabled = false
        submitButton.enabled = false
        activityIndicator.startAnimating()

        //attempt sign-in
        SessionManager.shared.logIn(credentials) { (result) in

            //reenable textfields
            self.emailTextfield.userInteractionEnabled = true
            self.passwordTextfield.userInteractionEnabled = true
            self.submitButton.enabled = true
            self.activityIndicator.stopAnimating()

            //check result
            switch result {
            case .Success(let patient):
                //Successful: call completionHandler
                self.completionHandler?(patient: patient)
            case .Error(_):
                //Failed: Display Error Message
                self.showError(message: "Something went wrong")
            }
        }
    }
}
