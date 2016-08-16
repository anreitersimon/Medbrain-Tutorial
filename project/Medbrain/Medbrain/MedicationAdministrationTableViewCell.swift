//
//  MedicationAdministrationTableViewCell.swift
//  Medbrain
//
//  Created by Simon Anreiter on 15/08/16.
//  Copyright © 2016 Simon Anreiter. All rights reserved.
//

import UIKit
import SMART

class MedicationAdministrationTableViewCell: UITableViewCell {

    static let dateFormatter: NSDateFormatter = {

        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        formatter.timeStyle = .ShortStyle

        return formatter
    }()

    func configure(administration: MedicationAdministration) {

        contentView.backgroundColor = UIColor.clearColor()
        textLabel?.backgroundColor = UIColor.clearColor()
        detailTextLabel?.backgroundColor = UIColor.clearColor()


        textLabel?.numberOfLines = 2

        if let date = administration.effectiveTimeDateTime?.date.nsDate ?? administration.effectiveTimePeriod?.start?.nsDate {
            detailTextLabel?.text = MedicationAdministrationTableViewCell.dateFormatter.stringFromDate(date)
        } else {
            detailTextLabel?.text = "-"
        }

        if let wasNotGiven = administration.wasNotGiven where wasNotGiven {
            textLabel?.text = "not taken on:"

            backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.2)
        } else {
            textLabel?.text = "taken on:"
            backgroundColor = UIColor.whiteColor()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
