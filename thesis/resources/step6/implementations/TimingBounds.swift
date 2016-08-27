//
//  TimingBounds.swift
//  Medbrain
//
//  Created by Simon Anreiter on 10/07/16.
//  Copyright © 2016 anreiter.simon. All rights reserved.
//

import Foundation

enum TimingBounds {
    case Duration(duration: Duration)
    case Period(start: NSDate?, end: NSDate?)
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
