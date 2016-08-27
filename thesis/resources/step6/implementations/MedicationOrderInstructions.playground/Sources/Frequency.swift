//
//  Frequency.swift
//  Medbrain
//
//  Created by Simon Anreiter on 10/07/16.
//  Copyright © 2016 anreiter.simon. All rights reserved.
//

import Foundation

public struct Frequency {
    public let frequency: Int
    public let max: Int?
}

extension Frequency: LocalizedSentenceBuildingSupport {
    public static var allFormatStrings: [String] {
        return [frequencySingle, frequencyRange]
    }

    public var formatString: String {
        return max == nil ? frequencySingle : frequencyRange
    }

    public var localizedArguments: [CVarArgType] {
        if let max = max {
            return [frequency, max]
        }
        return [frequency]
    }
}
