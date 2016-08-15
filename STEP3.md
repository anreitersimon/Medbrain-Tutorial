# Step 3 - Overview of used FHIR-Resources

#### Goals
- Get a understanding of the resources used in this app.
- Specify assumptions about the dataset.

## Overview

A quick overview of the important resources used.

Each resource will be explained more in depth in the corresponding section.

FHIR-Resources have very few required properties since it tries to support many healthcare-standards which may have different requirement

It is up to the developer to refine the definition of a sufficiently specified resource for the context it is used in.

As an orientation the `ELGA Implementierungsleitfaden` was used.

## Patient

This is the central resource since all data shown in the app is specific to __one__ patient which represents the user of the app.

[more information](FHIR-Resources/Patient/Patient.md)

## Medication
Represents a medication.

In the context of the app most medications are intended for the patient to consume.

[more information](FHIR-Resources/Medication/Medication.md)

## MedicationOrder
Represents a prescription in FHIR.
Expresses the order for the administration of a medication
it also includes specific `DosageInstructions`

[more information](FHIR-Resources/MedicationOrder/MedicationOrder.md)

## DosageInstructions
Contains information on timing, quantity and additional instructions on how to administer medications.

[more information](FHIR-Resources/DosageInstructions/DosageInstructions.md)

## MedicationAdministration
Represents the administration of a medication.

[more information](FHIR-Resources/MedicationAdministration/MedicationAdministration.md)


-------------


Next-up is Building the Application Structure

[Continue to Step 4 of the Tutorial](STEP4.md)
