# Step 2  - Managing Dependencies with CocoaPods

## Prerequisites

Finished [Step 1](STEP1.md) of this Tutorial.

If you want to start here you just run `git checkout step2`.

The Project is located at `project/` of the git repository root.

## Getting Started
[CocoaPods](https://cocoapods.org) is a tool for managing dependencies in iOS and Mac Applications.

A possible alternative is Apples `Swift Package Manager`.

Since CocoaPods is already very established and commonly seen as Best Practice, and the `Swift Package Manager` is still in beta stage CocoaPods is preferred.


1. Install CocoaPods:
If you haven't installed CocoaPods already go to the terminal and enter `sudo gem install cocoapods`
2. in the terminal go to your __working directory__ (Hint: `cd project/Medbrain`)
3. run `pod init`
This creates a file named `Podfile` in which you can specify your dependencies.
4. open the Podfile and change its contents to:

```ruby
platform :ios, '8.0'
use_frameworks!

target 'Medbrain' do
pod 'SMART', '~> 2.1'
end

target 'MedbrainTests' do
end

target 'MedbrainUITests' do
end

```

The `pod 'SMART'` installs the dependency [Swift-SMART](https://github.com/smart-on-fhir/Swift-SMART) which is a library simplifying the usage of FHIR-Resources within Swift Projects.

5. run `pod install`

This downloads all libraries specified in the Podfile and integrates them into the XCode project.

## Conclusion
You learned how to setup CocoaPods in a iOS-project and install dependencies.

Next-up is a overview of the used FHIR-Resources

[Continue to Step 3 of the Tutorial](STEP3.md)
