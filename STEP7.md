# Step 7 - Implementing MedicationDetailViewController

## Prerequisites
Finished [Step 6](STEP6.md) of this Tutorial.

If you want to start here you just run `git checkout step7`.

The Project is located at `project/` of the git repository root.

## Getting Started

When selecting a item in the `PatientMedicationsViewController` a `View` should be shown showing further details about the medication.

This view will be implemented in the `MedicationDetailViewController`. The view should show a graph with administrations for the specified medication.

Additionally a list of all administrations should be displayed.

In order to display the graph a new dependency will be introduced.

`ResearchKit` contains classes which can be used to render graphs:

### Adding the dependency

Edit your `Podfile` as follows:

```ruby
platform :ios, '8.0'
use_frameworks!

target 'Medbrain' do

pod 'SMART', '~> 2.1'
pod 'ResearchKit', '~> 1.3'
end

target 'MedbrainTests' do

end

target 'MedbrainUITests' do

end
```

This Step will be split up into parts
- Building the interface
- Loading result and displaying a list of all administrations
- Rendering a chart visualizing the timeline of the administrations

[Continue with Step 7.1 of the Tutorial](STEP7-1.md)
