//
//  CreateMedicationAdmistrationViewController.swift
//  Medbrain
//
//  Created by Simon Anreiter on 16/08/16.
//  Copyright © 2016 Simon Anreiter. All rights reserved.
//

import UIKit
import SMART

extension MedicationAdministration {
    convenience init(medicationOrder: MedicationOrder, patient: Patient, wasTaken: Bool, time: NSDate) {
        var json = FHIRJSON()
        //has to have a status
        json["status"] = "completed"
        //create a reference to the medicationOrder
        json["prescription"] = ["reference": "\(MedicationOrder.resourceName)/\(medicationOrder.id!)"]
        //reuse the medicationOrders reference to the medication
        json["medicationReference"] = medicationOrder.medicationReference?.asJSON()
        json["patient"] = patient.asJSON()
        json["wasNotGiven"] = !wasTaken
        json["effectiveTimePeriod"] = [
            "end": time.fhir_asDateTime().asJSON(),
            "start": time.fhir_asDateTime().asJSON()
        ]

        self.init(json: json)
    }
}


class CreateMedicationAdmistrationViewController: UIViewController {

    typealias CompletionHandler = (cancelled: Bool) -> Void

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var switchControl: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!

    var medicationOrder: MedicationOrder!

    var completionHandler: CompletionHandler?

    lazy var loadingBarbuttonItem: UIBarButtonItem = {
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        loadingIndicator.sizeToFit()

        loadingIndicator.startAnimating()

        return UIBarButtonItem(customView:loadingIndicator)
    }()

    @IBAction func cancelPressed(sender: AnyObject?) {
        completionHandler?(cancelled: true)
    }

    @IBOutlet var saveBarButtonItem: UIBarButtonItem!

    @IBAction func switchChanged(sender: AnyObject?) {
    }

    @IBAction func saveAdministration(sender: AnyObject?) {
        contentView.userInteractionEnabled = false
        contentView.alpha = 0.7


        let administration = MedicationAdministration(medicationOrder: medicationOrder,
                                                      patient: SessionManager.shared.patient!,
                                                      wasTaken: switchControl.on,
                                                      time: datePicker.date)

        navigationItem.rightBarButtonItem = loadingBarbuttonItem
        navigationItem.leftBarButtonItem?.enabled = false


        administration.create(SessionManager.shared.server) { [weak self] (error) in
            dispatch_async(dispatch_get_main_queue()) {

                guard let strongSelf = self else { return }

                if error != nil {
                    strongSelf.contentView.userInteractionEnabled = true
                    strongSelf.contentView.alpha = 1
                    strongSelf.navigationItem.rightBarButtonItem = strongSelf.saveBarButtonItem

                } else {
                    strongSelf.completionHandler?(cancelled: false)
                }
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updatePreferredContentSize()
    }

    func updatePreferredContentSize() {
        navigationController?.preferredContentSize = contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updatePreferredContentSize()
    }

}
