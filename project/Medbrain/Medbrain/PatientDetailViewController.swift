//
//  PatientDetailViewController.swift
//  Medbrain
//
//  Created by Simon Anreiter on 16/08/16.
//  Copyright © 2016 Simon Anreiter. All rights reserved.
//

import UIKit
import SMART

class PatientDetailViewController: UIViewController {

    @IBOutlet var loggedInContainer: UIView!
    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var lastNameLabel: UILabel!
    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!


    @IBOutlet var loggedOutContainer: UIView!
    @IBOutlet var logInButton: UIButton!
    @IBOutlet var logOutButton: UIButton!

    @IBOutlet var managingView: UIStackView!



    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loggedInPatientChanged(_:)), name: SessionManager.PatientChangedNotification, object: nil)

        configure(forPatient: SessionManager.shared.patient)
    }

    func loggedInPatientChanged(notification: NSNotification) {
        configure(forPatient: notification.userInfo?[SessionManager.PatientChangedNotificationNewKey] as? Patient)
    }

    func configure(forPatient patient: Patient?) {

        managingView.arrangedSubviews.forEach {
            managingView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        if let patient = patient {
            managingView.addArrangedSubview(loggedInContainer)


            firstNameLabel.text = patient.name?.first?.text ?? "-"
            lastNameLabel.text = patient.name?.last?.text ?? "-"
            phoneNumberLabel.text = patient.telecom?.first?.value ?? "-"
            addressLabel.text = patient.address?.first?.text ?? "-"
        } else {
            managingView.addArrangedSubview(loggedOutContainer)
        }
    }


    @IBAction func logoutPressed(sender: AnyObject?) {
        SessionManager.shared.logout()
    }

}
