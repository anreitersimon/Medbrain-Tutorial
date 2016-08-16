# Step 8.2 - Implementing CreateMedicationAdministrationViewController - Creating the MedicationAdministration on the server.

Some setup is needed to be able to create the resource on the server.

1. The `MedicationAdministration` is created for a specific `medicationOrder` so create a property `medicationOrder`.
```swift
var medicationOrder: MedicationOrder!
```
2. Add a `completionHandler` property which is called when the task is finished.
>__Note:__ Since the user can cancel the creation of the resource finishing the task can mean it was cancelled.
> For this purpose the completionHandler contains a `Bool` flag named `cancelled`

```swift
typealias CreateAdministrationCompletionHandler = (cancelled: Bool)->Void

var completionHandler :CreateAdministrationCompletionHandler?

```

3. In the `MedicationDetailViewController` implement the `prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)` method as follows:

```swift
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "createAdministration" {
            let createController = (segue.destinationViewController as! UINavigationController).topViewController as! CreateMedicationAdmistrationViewController

            //pass the medicationOrder to the `CreateMedicationAdmistrationViewController`
            createController.medicationOrder = medicationOrder

            //Dismiss the CreateMedicationAdmistrationViewController after it is finished
            //Reload the administrations if the creation was successfull (not cancelled)
            createController.completionHandler = { (cancelled) in
                self.dismissViewControllerAnimated(true, completion: {
                    if !cancelled {
                        self.loadContent()
                    }
                })
            }
        }
    }
```


#### Implementing actions

When the user presses the `cancelBarButtonItem` the `cancelPressed(sender: AnyObject?)` method is invoked.
Implement the method as follows:
```swift
@IBAction func cancelPressed(sender: AnyObject?) {
    //call the completion handler with cancelled=true
    completionHandler?(cancelled: true)
}
```

When the `saveBarButtonItem` is pressed to persist the configured  `MedicationAdministration` the  `func saveAdministration(sender: AnyObject?)` function should perform the following tasks:
- Disable the editable views as well as the `save` and `cancel` buttons.
- Create a instance of `MedicationAdministration` using the data entered before.
- Perform the Server-Request to create the resource.
  - If successful call the `completionHandler`
  - If an error occurred display a error message and reenable all previously disabled elements.

>__Note:__ The `SMART` framework provides no way to create resources other then initializing them with a `FHIRJSON` instance.
>`FHIRJSON` represents a JSON-Object and is defined as `public typealias FHIRJSON = [String: AnyObject]`


to create a `MedicationAdministration` a convenience initializer for it is introduced in an extension of `MedicationAdministration`.

```swift
extension MedicationAdministration {
    convenience init(medicationOrder: MedicationOrder, patient: Patient, wasTaken: Bool, time: NSDate) {
        var json = FHIRJSON()
        //has to have a status
        json["status"] = "completed"
        //create a reference to the medicationOrder
        json["prescription"] = ["reference": "\(MedicationOrder.resourceName)/\(medicationOrder.id!)"]
        //reuse the medicationOrders reference to the medication
        json["medicationReference"] = medicationOrder.medicationReference?.asJSON()
        json["patient"] = patient.asJSON()
        json["wasNotGiven"] = !wasTaken
        json["effectiveTimePeriod"] = [
            "end": time.fhir_asDateTime().asJSON(),
            "start": time.fhir_asDateTime().asJSON()
        ]

        //use designated initializer with the json
        self.init(json: json)
    }
}
```

Now that a `MedicationAdministration` can be created locally it has to be created on the server.

Implement the `func saveAdministration(sender: AnyObject?)` function like this:

```swift
@IBAction func saveAdministration(sender: AnyObject?) {

    //create administration locally
    let administration = MedicationAdministration(medicationOrder: medicationOrder,
                                                  patient: SessionManager.shared.patient!,
                                                  wasTaken: switchControl.on,
                                                  time: datePicker.date)

    //Disable controls
    switchControl.userInteractionEnabled = false
    datePicker.userInteractionEnabled = false
    saveBarButtonItem.enabled = false
    cancelBarButtonItem.enabled = false

    //Attempt to create resource on server
    administration.create(SessionManager.shared.server) { [weak self] (error) in
        dispatch_async(dispatch_get_main_queue()) {

            guard let strongSelf = self else { return }

            if error != nil {
              //Reenable controls
              strongSelf.switchControl.userInteractionEnabled = true
              strongSelf.datePicker.userInteractionEnabled = true
              strongSelf.saveBarButtonItem.enabled = true
              strongSelf.cancelBarButtonItem.enabled = true

              //Show error message
              let alertController = UIAlertController(title: "Something went wrong", message: nil, preferredStyle: .Alert)
              alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))

              strongSelf.presentViewController(alertController, animated: true, completion: nil)

            } else {
                strongSelf.completionHandler?(cancelled: false)
            }
        }
    }
}
```
