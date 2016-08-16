//
//  MedicationOrderTableViewCell.swift
//  Medbrain
//
//  Created by Simon Anreiter on 15/08/16.
//  Copyright © 2016 Simon Anreiter. All rights reserved.
//

import UIKit
import SMART

class MedicationOrderTableViewCell: UITableViewCell {

    func configure(medicationOrder: MedicationOrder) {
        self.textLabel?.text = medicationOrder.medicationName
        self.detailTextLabel?.text = medicationOrder.localizedInstructions
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
