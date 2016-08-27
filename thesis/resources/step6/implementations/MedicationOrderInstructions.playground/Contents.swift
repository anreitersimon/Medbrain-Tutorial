//: Playground - noun: a place where people can play

import Foundation
import XCPlayground

let sentenceStructure: [LocalizedSentenceBuildingSupport.Type] = [
    Frequency.self,
    Period.self,
    EventTiming.self,
    Duration.self,
    TimingBounds.self
]

///prefixes all sentences with "timing"
func timingStrings(from possibilities: [[String]])->Set<String> {
    var actual = possibilities
    actual.insert(["timing"], atIndex: 0)
    
    return Set(actual.combinations.map({ $0.joinWithSeparator("")}))
}

var sentences = sentenceStructure.map { $0.optionalFormatStrings }

let allSentences = timingStrings(from: sentences)
var validSentences = allSentences

//when and frequency are mutually exclusive
//Find all combinations where BOTH are present
let whenAndFrequencyPresent = timingStrings(from: [
    Frequency.allFormatStrings,
    Period.optionalFormatStrings,
    EventTiming.allFormatStrings,
    Duration.optionalFormatStrings,
    TimingBounds.optionalFormatStrings
    ])


///subtract invalid sentences
validSentences.subtractInPlace(whenAndFrequencyPresent)


validSentences.forEach {
    print($0)
}