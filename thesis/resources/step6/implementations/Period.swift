//
//  Period.swift
//  Medbrain
//
//  Created by Simon Anreiter on 10/07/16.
//  Copyright © 2016 anreiter.simon. All rights reserved.
//

import Foundation

struct Period {
    let value: Double
    let valueMax: Double?
    let unit: TimingUnit

    init?(_ value: NSDecimalNumber?, valueMax: NSDecimalNumber?, unit: String?) {
        guard let duration = value?.doubleValue, unit = TimingUnit(unit) else {
            return nil
        }
        self.value = duration
        self.valueMax = valueMax?.doubleValue
        self.unit = unit
    }
}

extension Period: LocalizedSentenceBuildingSupport {

    static var allFormatStrings: [String] {
        return ["", periodSingle, periodRange]
    }

    var formatString: String {
        return self.valueMax == nil ? periodSingle : periodRange
    }

    var localizedArguments: [CVarArgType] {
        if let max = valueMax {
            return [unit.localized(period: Int(value)), unit.localized(period: Int(max))]
        } else {
            return [unit.localized(period: Int(value))]
        }
    }
}

extension Period: Equatable { }

func == (lhs: Period, rhs: Period) -> Bool {
    return lhs.value == rhs.value && lhs.unit == rhs.unit
}
