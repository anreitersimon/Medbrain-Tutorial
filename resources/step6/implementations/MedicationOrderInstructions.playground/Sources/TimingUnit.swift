//
//  TimingUnit.swift
//  Medbrain
//
//  Created by Simon Anreiter on 10/07/16.
//  Copyright © 2016 anreiter.simon. All rights reserved.
//

import Foundation

/**
 For more information see: [Units of Time](https://www.hl7.org/fhir/valueset-units-of-time.html)

 Represents a unit of time i.e.: seconds.

 Provides  `name` and `pluralizedName` properties for use when building a textual description.
 */

public enum TimingUnit: String {
    case Second = "s"
    case Minute = "min"
    case Hour = "h"
    case Day = "d"
    case Week = "wk"
    case Month = "mo"

    init?(_ rawValue: String) {
        self.init(rawValue: rawValue)
    }

    init?(_ rawValue: String?) {
        guard let value = rawValue else { return nil }
        self.init(rawValue: value)
    }

    public var durationLocalizationKey: String {
        switch self {
        case .Second:
            return "for %d second(s)"
        case .Minute:
            return "for %d minute(s)"
        case .Hour:
            return "for %d hour(s)"
        case .Day:
            return "for %d day(s)"
        case .Week:
            return "for %d week(s)"
        case .Month:
            return "for %d month(s)"
        }
    }

    public var periodLocalizationKey: String {
        switch self {
        case .Second:
            return "every %d second(s)"
        case .Minute:
            return "every %d minute(s)"
        case .Hour:
            return "every %d hour(s)"
        case .Day:
            return "every %d day(s)"
        case .Week:
            return "every %d week(s)"
        case .Month:
            return "every %d month(s)"
        }
    }

    public func localized(duration duration: Int) -> String {
        let str = String.localizedStringWithFormat(NSLocalizedString(durationLocalizationKey, comment: ""), duration)

        return str
    }

    public func localized(period period: Int) -> String {
        let str = String.localizedStringWithFormat(NSLocalizedString(periodLocalizationKey, comment: ""), period)

        return str
    }

    public var name: String {
        switch self {
        case .Second:
            return "second"
        case .Minute:
            return "minute"
        case .Hour:
            return "hour"
        case .Day:
            return "day"
        case .Week:
            return "week"
        case .Month:
            return "month"
        }
    }

}
