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


    @IBAction func submitButtonPressed(sender: AnyObject?) {
        //will be implemented later
    }
}
