//
//  Duration.swift
//  Medbrain
//
//  Created by Simon Anreiter on 10/07/16.
//  Copyright © 2016 anreiter.simon. All rights reserved.
//

import Foundation

public typealias IDuration = Duration

public struct Duration {
    public let value: Double
    public let valueMax: Double?
    public let unit: TimingUnit

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

    public static var allFormatStrings: [String] {
        return [durationSingle, durationRange]
    }

    public var formatString: String {
        return valueMax == nil ? durationSingle : durationRange
    }
    public var localizedArguments: [CVarArgType] {
        if let max = valueMax {
            return [unit.localized(duration: Int(value)), unit.localized(duration: Int(max))]
        } else {
            return [unit.localized(duration: Int(value))]
        }
    }
}

extension Duration: Equatable { }

public func == (lhs: Duration, rhs: Duration) -> Bool {
    return lhs.value == rhs.value && lhs.unit == rhs.unit
}
