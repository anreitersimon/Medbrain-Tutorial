//
//  MedicationOrder+Instructions.swift
//  Medbrain
//
//  Created by Simon Anreiter on 15/08/16.
//  Copyright © 2016 Simon Anreiter. All rights reserved.
//

import Foundation
import SMART

extension SMART.MedicationOrder {

    var localizedInstructions: String {
        //No instructions to generate
        guard let repeat_fhir = dosageInstruction?.first?.timing?.repeat_fhir else {
            return "no instructions"
        }


        let optionalSentenceParts: [LocalizedSentenceBuildingSupport?] = [
            Frequency(repeat_fhir),
            Period(repeat_fhir.period, valueMax: repeat_fhir.periodMax, unit: repeat_fhir.periodUnits),
            EventTiming(repeat_fhir.when),
            Duration(repeat_fhir.duration, valueMax: repeat_fhir.durationMax, unit: repeat_fhir.durationUnits),
            TimingBounds(repeat_fhir)
        ]

        //eliminiate all items which are nil
        let sentenceParts = optionalSentenceParts.flatMap { $0 }

        //builder string for sentence
        var sentence = "timing"
        //arguments to use
        var arguments = [CVarArgType]()


        //combine all sentence parts and arguments
        sentenceParts.forEach {
            sentence += $0.formatString
            arguments.appendContentsOf($0.localizedArguments)
        }

        //Lookup string in Localizable.stringsdict and return result
        return String(format: NSLocalizedString(sentence, comment: ""), locale: NSLocale.currentLocale(), arguments: arguments)
    }

    var medicationName: String {
        if let medname = medicationCodeableConcept?.coding?.first?.display {
            return medname
        }

        if let display = medicationReference?.display {
            return display
        }

        return "No medicationname"
    }
}
