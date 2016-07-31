
## MedicationOrder
https://www.hl7.org/fhir/medicationorder.html

An order for supply and administration of the medication to a patient.

A `MedicationOrder` can only be created by a `Practitioner` and never by a `Patient`.

Therefore the app only requires read-only access to a patients medication-orders

### UML

![](MedicationOrder-UML.png)

##### Requirements

 requirement                    | expression                                      | required
--------------------------------|-------------------------------------------------|-------------
at least one dosageInstruction  | `medicationOrder.dosageInstructions[0] != null` | yes
prescribed for a patient        | `medicationOrder.patient != null`               | yes
has medication                  | `medicationOrder.medication != null`            | yes


##### Example
[MedicationOrder.xml](examples/medicationOrder.xml)

This resource is referenced by:
```
CarePlan, Claim, ClinicalImpression, MedicationAdministration, MedicationDispense
```
