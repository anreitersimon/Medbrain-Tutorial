# Step 1 - Project Setup

## Prerequisites
- Installed XCode 7.3 (Current Version as of writing this)

## Getting Started
1. Create your __working directory__
for example run `mkdir medbrain` in the Terminal
2. Open XCode and create a new Project
![](resources/step1/step_1_1.png)

3. In the following screen select `Single View Application`
![](resources/step1/step_1_2.png)
This template will create an iOS-App with a single empty screen.

4. Enter a Productname for the project (In our case this is `Medbrain`)

![Info ](resources/step1/step_1_3.png)

Note: the `Organization Identifier` and `Bundle Identifier` typically follows a reverse-DNS-format.

The `Bundle Identifier` is used to uniquely identify your app (i.e.: in the iTunes AppStore)

By Default this is set by the following Schema `${Organization Identifier}.${Product Name}` but can be set manually at a later point.

5. When prompted where to create the project select the previously created __working directory__
