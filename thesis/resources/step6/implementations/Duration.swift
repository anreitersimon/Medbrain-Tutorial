//
//  Duration.swift
//  Medbrain
//
//  Created by Simon Anreiter on 10/07/16.
//  Copyright © 2016 anreiter.simon. All rights reserved.
//

import Foundation

struct Duration {
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

extension Duration: LocalizedSentenceBuildingSupport {

    static var allFormatStrings: [String] {
        return ["", durationSingle, durationRange]
    }

    var formatString: String {
        return valueMax == nil ? durationSingle : durationRange
    }
    var localizedArguments: [CVarArgType] {
        if let max = valueMax {
            return [unit.localized(duration: Int(value)), unit.localized(duration: Int(max))]
        } else {
            return [unit.localized(duration: Int(value))]
        }
    }
}

extension Duration: Equatable { }

func == (lhs: Duration, rhs: Duration) -> Bool {
    return lhs.value == rhs.value && lhs.unit == rhs.unit
}
