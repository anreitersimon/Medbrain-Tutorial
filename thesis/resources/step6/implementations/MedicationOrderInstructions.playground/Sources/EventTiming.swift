//
//  EventTiming.swift
//  Medbrain
//
//  Created by Simon Anreiter on 10/07/16.
//  Copyright © 2016 anreiter.simon. All rights reserved.
//

import Foundation

/**
 [http://hl7.org/fhir/v3/TimingEvent](http://hl7.org/fhir/v3/TimingEvent)
 */
public enum EventTiming: String {
    init?(_ rawValue: String?) {
        guard let value = rawValue else { return nil }
        self.init(rawValue: value)
    }

    /// before sleep
    case BeforeSleep = "HS"

    /// upon waking up
    case Wake = "WAKE"

    /// meal
    case Meal = "C"

    /// breakfast
    case Breakfast = "CM"

    /// lunch
    case Lunch = "CD"

    /// dinner
    case Dinner = "CV"

    /// before meal
    case BeforeMeal = "AC"

    /// before breakfast
    case BeforeBreakFast = "ACM"

    /// before lunch
    case BeforeLunch = "ACD"

    /// before dinner
    case BeforeDinner = "ACV"

    /// after meal
    case AfterMeal = "PC"

    /// after breakfast
    case AfterBreakfast = "PCM"

    /// after lunch
    case AfterLunch = "PCD"

    /// after dinner
    case AfterDinner = "PCV"

    var description: String {
        switch self {

        case .BeforeSleep:
            return "before sleep"

        case .Wake:
            return "upon waking up"

        case .Meal:
            return "meal"

        case .Breakfast:
            return "breakfast"

        case .Lunch:
            return "lunch"

        case .Dinner:
            return "dinner"

        case .BeforeMeal:
            return "before meal"

        case .BeforeBreakFast:
            return "before breakfast"

        case .BeforeLunch:
            return "before lunch"

        case .BeforeDinner:
            return "before dinner"

        case .AfterMeal:
            return "after meal"

        case .AfterBreakfast:
            return "after breakfast"

        case .AfterLunch:
            return "after lunch"

        case .AfterDinner:
            return "after dinner"
        }
    }
}

extension EventTiming: LocalizedSentenceBuildingSupport {

    public static var allFormatStrings: [String] {
        return [beforeEvent]
    }

    public var formatString: String {
        return beforeEvent
    }
    public var localizedArguments: [CVarArgType] {
        return [self.rawValue]
    }

}
