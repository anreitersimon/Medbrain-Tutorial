//
//  LocalizedSentenceBuildingSupport.swift
//  Medbrain
//
//  Created by Simon Anreiter on 15/08/16.
//  Copyright © 2016 anreiter.simon. All rights reserved.
//

import Foundation

public let beforeEvent = "_with_event(event:%@)"
public let durationSingle = "_for_(duration:%@)"
public let durationRange = "_for_(duration_range:%@)"
public let frequencySingle = "_times(count:%#@freq@)"
public let frequencyRange = "_times(range:%#@freq@ to %#@freq_max@)"
public let periodSingle = "_per_(period:%@)"
public let periodRange = "_per_(period_range:%@)"
public let timingBoundsDuration = "_bounds_(duration:%@)"
public let timingBoundsRange = "_bounds_(range:%@)"

protocol LocalizedSentenceBuildingSupport {
    static var allFormatStrings: [String] { get }

    var formatString: String { get }
    var localizedArguments: [CVarArgType] { get }
}
