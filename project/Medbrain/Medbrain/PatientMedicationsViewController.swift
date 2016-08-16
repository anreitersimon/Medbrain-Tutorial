//
//  PatientMedicationsViewController.swift
//  Medbrain
//
//  Created by Simon Anreiter on 16/08/16.
//  Copyright © 2016 Simon Anreiter. All rights reserved.
//

import UIKit

enum State {
    //Starting state show nothing
    case Initial

    //Fetching medications from the server
    case LoadingResults

    //Fetching medications failed
    case Error

    //Fetching medications succeeded but list was empty
    case Empty

    //Fetching medications succeeded
    case Loaded


    var showsStatusView: Bool {
        switch self {
        case .Initial, .LoadingResults, .Error, .Empty:
            return true
        case .Loaded:
            return false
        }
    }

    var showsLoadingIndicator: Bool {
        switch self {
        case .LoadingResults:
            return true
        case .Initial, .Error, .Empty, .Loaded:
            return false
        }
    }

    var title: String? {
        switch self {
        case .Initial:
            return nil
        case .LoadingResults:
            return "Loading..."
        case .Error:
            return "Error"
        case .Empty:
            return "No Prescriptions"
        case .Loaded:
            return nil
        }
    }
}

class PatientMedicationsViewController: UITableViewController {

    @IBOutlet var statusView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusTitleLabel: UILabel!

    var state: State = .Initial {
        didSet {
            configure(forState: state)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundView = statusView

        //configure the statusView for the current state
        configure(forState: state)
    }

    func configure(forState state: State) {
        statusView.hidden = !state.showsStatusView

        statusTitleLabel.hidden = state.title?.isEmpty ?? true
        statusTitleLabel.text = state.title ?? " "


        if activityIndicator.isAnimating() && !state.showsLoadingIndicator {
            activityIndicator.stopAnimating()
        } else if !activityIndicator.isAnimating() && state.showsLoadingIndicator {
            activityIndicator.startAnimating()
        }

        statusView.setNeedsLayout()
        statusView.layoutIfNeeded()
    }
}
