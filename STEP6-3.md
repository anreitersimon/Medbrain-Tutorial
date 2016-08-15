### Implementing PatientMedicationsViewController -  Generating instructions for prescriptions

When displaying a list-item in the `PatientMedicationsViewController` as well as in the `MedicationDetailViewController` instructions should be shown.

These instructions should be generated from the data contained in the `MedicationOrder`

When generating these instructions its important to make as few assumptions about grammatical structures as possible as these may vary from language to language.

To address this issue these descriptions are built using LocalizedStrings.

Strings are not used directly but are stored in a file (`Localizable.stringsdict`) and are referred to by keys.

There should exist a file for each supported language.

for instance when describing a duration in seconds:
```xml
<key>for %d second(s)</key>
<dict>
  <key>NSStringLocalizedFormatKey</key>
  <string>%#@value@</string>
  <key>value</key>
  <dict>
    <key>NSStringFormatSpecTypeKey</key>
    <string>NSStringPluralRuleType</string>
    <key>NSStringFormatValueTypeKey</key>
    <string>d</string>
    <key>one</key>
    <string>for one second</string>
    <key>other</key>
    <string>for %d seconds</string>
  </dict>
</dict>
```
In this example the key is `"for %d seconds"`

Additionally a pluralization rule is defined.
So for instance when the duration is 1 (singular) the result is `"for one second"` as in all other cases it is `"for x seconds"`

To simplify the generation `DosageInstructions` some convenience classes/structs were introduced.

#### TimingUnit
String enum wrapping the units of time used by FHIR.

More information can be found here. [here](https://www.hl7.org/fhir/valueset-units-of-time.html)

```swift

enum TimingUnit: String {
    case Second = "s"
    case Minute = "min"
    case Hour = "h"
    case Day = "d"
    case Week = "wk"
    case Month = "mo"
}
```

#### EventTiming
String enum wrapping the codes for events used in FHIR

More information can be found [here](http://hl7.org/fhir/v3/TimingEvent)

```swift
enum EventTiming: String {
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
}
```

#### Duration
Encapsulates a Duration.
>__Note:__ The duration may also be defined as a range. (`valueMax != nil`)

```swift
struct Duration {
    let value: Double
    let valueMax: Double?
    let unit: TimingUnit

    init?(_ value: NSDecimalNumber?, valueMax: NSDecimalNumber?, unit: String?) {
        guard let duration = value?.doubleValue, unit = TimingUnit(unit) else {
            return nil
        }
        self.value = duration
        self.valueMax = valueMax?.doubleValue
        self.unit = unit
    }
}
```


#### Frequency
Encapsulates a Frequency
>__Note:__ The frequency may also be defined as a range. (`max != nil`)

```swift
struct Frequency {
    let frequency: Int
    let max: Int?
}

extension Frequency {
    ///convenience initializer for creating frequency from a FHIR TimingRepeat
    init?(_ timing: TimingRepeat) {
        guard let frequency = timing.frequency else {
            return nil
        }
        self.frequency = frequency
        self.max = timing.frequencyMax
    }
}
```

#### Period
Encapsulates a Period of time
>__Note:__ The period may also be defined as a range. (`valueMax != nil`)

```swift
struct Period {
    let value: Double
    let valueMax: Double?
    let unit: TimingUnit

    init?(_ value: NSDecimalNumber?, valueMax: NSDecimalNumber?, unit: String?) {
        guard let duration = value?.doubleValue, unit = TimingUnit(unit) else {
            return nil
        }
        self.value = duration
        self.valueMax = valueMax?.doubleValue
        self.unit = unit
    }
}
```


#### TimingBounds
Describes timing bounds used in FHIR.

This is modelled as an enum which wraps a value as enums are mutually exclusive. (Either a `Duration` or a `Period` but never both)


```swift
enum TimingBounds {
    case Duration(duration: Medbrain.Duration)
    case Period(start: NSDate?, end: NSDate?)

    init?(_ timing: TimingRepeat) {
        if let period = timing.boundsPeriod {
            self = .Period(start: period.start?.nsDate, end: period.end?.nsDate)
        } else if let quantity = timing.boundsQuantity {
            guard let duration = Medbrain.Duration(quantity.value, valueMax: nil, unit: quantity.unit) else {
                    return nil
            }

            self = .Duration(duration: duration)
        }
        return nil
    }
}
```
## Bringing it together

The generated instruction is a "sentence" where every of the items described above  may contribute a part of that sentence.

Each "sentence" should be a key in the `Localizable.stringsdict` file.

To express this in code a protocol named `LocalizedSentenceBuildingSupport` was introduced.
>__Note:__ A protocol is the swift equivalent of an interface in java

elements which adopt this protocol provide a part of a sentence.

```swift
protocol LocalizedSentenceBuildingSupport {
    ///return all possibilities
    ///Note: this is not necessarily required for building the sentence but is useful for generating all possible sentences of a combination of sentenceParts
    static var allFormatStrings: [String] { get }

    var formatString: String { get }
    var localizedArguments: [CVarArgType] { get }
}
```
Each of the items described above adopt this protocol.
The implementations can be found here.
- [Frequency](resources/step6/Frequency.swift)
- [Period](resources/step6/Period.swift)
- [EventTiming](resources/step6/EventTiming.swift)
- [Duration](resources/step6/Duration.swift)
- [TimingBounds](resources/step6/TimingBounds.swift)

The sentence built by a `MedicationOrder` follows the following pattern.
>__Note:__ Each element is optional

1. Frequency
2. Period
3. EventTiming
4. Duration
5. TimingBounds

Since there are many possible combinations a playground was implemented generating all required keys.

It can be found at `resources/step6/implementations/MedicationOrderInstructions.playground`
[MedicationOrderInstructions.playground](resources/step6/implementations/MedicationOrderInstructions.playground)


Since the generated instructions will be used in various places in the app it does not make sense to implement this in the `PatientMedicationsViewController`

As a reusable solution the instructions will be exposed as a computed property on the `MedicationOrder` class.

Additionally a convenience accessor for the medicationName will be implemented

Create a new file named `MedicationOrder+Instructions.swift`
>__Note:__ It is Swift Convention when adding a extension to a existing class/struct to place the implementation in a File named `ExtendedClass+ExtensionName.swift`

```swift
import SMART

extension SMART.MedicationOrder {

    var localizedInstructions: String {
        //No instructions to generate
        guard let repeat_fhir = dosageInstruction?.first?.timing?.repeat_fhir else {
            return "no instructions"
        }


        let optionalSentenceParts: [LocalizedSentenceBuildingSupport?] = [
            Frequency(repeat_fhir),
            Period(repeat_fhir.period, valueMax: repeat_fhir.periodMax, unit: repeat_fhir.periodUnits),
            EventTiming(repeat_fhir.when),
            Duration(repeat_fhir.duration, valueMax: repeat_fhir.durationMax, unit: repeat_fhir.durationUnits),
            TimingBounds(repeat_fhir)
        ]

        //eliminiate all items which are nil
        let sentenceParts = optionalSentenceParts.flatMap { $0 }

        //builder string for sentence
        var sentence = "timing"
        //arguments to use
        var arguments = [CVarArgType]()


        //combine all sentence parts and arguments
        sentenceParts.forEach {
            sentence += $0.formatString
            arguments.appendContentsOf($0.localizedArguments)
        }

        //Lookup string in Localizable.stringsdict and return result
        return String(format: NSLocalizedString(sentence, comment: ""), locale: NSLocale.currentLocale(), arguments: arguments)
    }

    ///The name of the prescribed medication
    var medicationName: String {
        if let medname = medicationCodeableConcept?.coding?.first?.display {
            return medname
        }

        if let display = medicationReference?.display {
            return display
        }

        return "No medicationname"
    }
}
```

[Continue with Part 4 of this Step](STEP6-4.md)
