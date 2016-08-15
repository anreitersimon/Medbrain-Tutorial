//
//  TimingBounds.swift
//  Medbrain
//
//  Created by Simon Anreiter on 10/07/16.
//  Copyright © 2016 anreiter.simon. All rights reserved.
//

import Foundation

public enum TimingBounds {
    case Duration(duration: IDuration)
    case Period(start: NSDate?, end: NSDate?)
}

extension TimingBounds: LocalizedSentenceBuildingSupport {
    public static var allFormatStrings: [String] {
        return [timingBoundsRange, timingBoundsRange]
    }

    public var formatString: String {
        switch self {
        case .Duration(_):
            return timingBoundsDuration
        case .Period(_, _):
            return timingBoundsRange
        }
    }

    public var localizedArguments: [CVarArgType] {
        return [""]
    }
}
