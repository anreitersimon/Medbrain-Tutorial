//
//  TimingBounds.swift
//  Medbrain
//
//  Created by Simon Anreiter on 10/07/16.
//  Copyright © 2016 anreiter.simon. All rights reserved.
//

import Foundation
import SMART

enum TimingBounds {
    case Duration(duration: Medbrain.Duration)
    case Period(start: NSDate?, end: NSDate?)

    init?(_ timing: TimingRepeat) {
        if let period = timing.boundsPeriod {
            self = .Period(start: period.start?.nsDate, end: period.end?.nsDate)
        } else if let quantity = timing.boundsQuantity {
            guard let duration = Medbrain.Duration(quantity.value, valueMax: nil, unit: quantity.unit) else {
                    return nil
            }

            self = .Duration(duration: duration)
        }
        return nil
    }
}

extension TimingBounds: LocalizedSentenceBuildingSupport {
    static var allFormatStrings: [String] {
        return ["", timingBoundsRange, timingBoundsRange]
    }

    var formatString: String {
        switch self {
        case .Duration:
            return timingBoundsDuration
        case .Period:
            return timingBoundsRange
        }
    }

    var localizedArguments: [CVarArgType] {
        return [""]
    }
}
