
### MedicationOrder

An order for supply and administration of the medication to a patient.

A `MedicationOrder` can only be created by a `Practitioner` and never by a `Patient`.

Therefore the app only requires read-only access to a patients medication-orders.

##### Requirements
In the app it is assumed that a `MedicationOrder` has a medication.

 requirement                    | expression                                      
--------------------------------|-------------------------------------------------
at least one dosageInstruction  | `medicationOrder.dosageInstructions[0] != null`
prescribed for a patient        | `medicationOrder.patient != null`               
has medication                  | `medicationOrder.medication != null`            


#### This resource is referenced by:
```
CarePlan, Claim, ClinicalImpression, MedicationAdministration, MedicationDispense
```
