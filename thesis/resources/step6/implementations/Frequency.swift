//
//  Frequency.swift
//  Medbrain
//
//  Created by Simon Anreiter on 10/07/16.
//  Copyright © 2016 anreiter.simon. All rights reserved.
//

import Foundation
import SMART

struct Frequency {
    let frequency: Int
    let max: Int?
}


extension Frequency: LocalizedSentenceBuildingSupport {
    static var allFormatStrings: [String] {
        return ["", frequencySingle, frequencyRange]
    }

    var formatString: String {
        return max == nil ? frequencySingle : frequencyRange
    }

    var localizedArguments: [CVarArgType] {
        if let max = max {
            return [frequency, max]
        }
        return [frequency]
    }
}
