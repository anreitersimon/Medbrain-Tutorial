//
//  NSDate+DateGrouping.swift
//  Medbrain
//
//  Created by Simon Anreiter on 16/08/16.
//  Copyright © 2016 Simon Anreiter. All rights reserved.
//

import Foundation

extension NSDate {
    func predecessor(groupingMode mode: DateGroupingMode) -> NSDate {
        let calendar = NSCalendar.currentCalendar()

        let components = NSDateComponents()

        switch mode {
        case .Day:
            components.day = -1
        case .Week:
            components.weekOfYear = -1
        case .Month:
            components.month = -1
        case .Year:
            components.year = -1
        }

        return calendar.dateByAddingComponents(components, toDate: self, options: NSCalendarOptions.MatchStrictly)!
    }

    func identifier(groupingMode mode: DateGroupingMode) -> String {

        let units: NSCalendarUnit

        switch mode {
        case .Day:
            units = [ .Year, .Month, .Day ]
        case .Week:
            units = [ .Year, .WeekOfYear ]
        case .Month:
            units = [ .Year, .Month]
        case .Year:
            units = [ .Year]
        }


        let calendar = NSCalendar.currentCalendar()


        let components = calendar.components(units, fromDate: self)

        switch mode {
        case .Day:
            return String(format: "%04d-%02d-%02d", components.year, components.month, components.day)
        case .Week:
            return String(format: "%04d-%02d", components.year, components.weekOfYear)
        case .Month:
            return String(format: "%04d-%02d", components.year, components.month)
        case .Year:
            return String(format: "%04d", components.year)
        }
    }
}
