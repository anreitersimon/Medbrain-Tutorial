# Step 4 - Building the Application Flow

## Prerequisites
Finished [Step 2](STEP2.md) of this Tutorial.

If you want to start here you just run `git checkout step4`.

The Project is located `project/` of the git repository root.

## Goals
In this step the each of the apps screens will be added as a placeholder implementation.
Each screens functionality will be implemented later on.

Learn about building UserInterfaces utilizing X-Codes Interface-Builder and Storyboards.

## Getting started
By default X-Code creates a storyboard name `Main.storyboard`.

It contains a single `ViewController`.

We start of by deleting the `ViewController` and its corresponding ViewController implementation.

- Delete the file `ViewController.swift`
- Select file `Main.storyboard` in the project navigator.
- Select the empty ViewController and delete it.


##### Adding the TabBarController
- From the Interface-Builders Object library drag a `Tab Bar Controller` object onto the storyboard.
- Select the newly added controller and in the `Attributes Inspector` select the checkbox `Is Initial ViewController`

![](resources/step4/add_tabbar.gif)


##### Replacing the ChildControllers
- First delete the to ChildControllers
- Select a `Navigation Controller`from the object-library and drag it onto the storyboard.
>__Note:__ this also adds a empty `Table View Controller`

- Drag a `View Controller` from the object-library onto the storyboard.
- `ctrl` + drag from the `Tab Bar Controller` to the `Navigation Controller`
- select `viewcontrollers` in the `Relationship-Segue` section

- `ctrl` + drag from the `Tab Bar Controller` to the `Navigation Controller`
- select `viewcontrollers` in the `Relationship-Segue` section

![](resources/step4/replace_tabbars.gif)





Create a view which shows a list of all patients prescriptions.

A prescription is modelled in FHIR as [MedicationOrder](https://www.hl7.org/fhir/medicationorder.html).

Each list-item corresponds to one prescription.
The information in each list-item is very limited, upon clicking a item a detail-view
showing more detailed information is shown (this will be implemented in the next step).


so the first priority is to sign-in.

For the implementation we will introduce following classes:

- SessionManager
- SignInViewController
- PatientDetailViewController


##### SessionManager
- Implemented as a singleton.
- Its responsibility is to manage the currently signed in patient.
- handle log-out

##### SignInViewController
-


in addition a new dependency will be introduced.


A prescription is modelled in FHIR as [MedicationOrder](https://www.hl7.org/fhir/medicationorder.html).

Each list-item corresponds to one prescription.
The information in each list-item is very limited, upon clicking a item a detail-view
showing more detailed information is shown (this will be implemented in the next step).


## Assumptions
- each `Medication` has a display-name: at keypath: `$(medication).code.coding.display`
