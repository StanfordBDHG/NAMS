<!--

This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project

SPDX-FileCopyrightText: 2023 Stanford University

SPDX-License-Identifier: MIT

-->

# Neurodevelopment Assessment and Monitoring System (NAMS)

[![Beta Deployment](https://github.com/StanfordBDHG/NAMS/actions/workflows/beta-deployment.yml/badge.svg)](https://github.com/StanfordBDHG/NAMS/actions/workflows/beta-deployment.yml)
[![codecov](https://codecov.io/gh/StanfordBDHG/NAMS/branch/main/graph/badge.svg?token=9fvSAiFJUY)](https://codecov.io/gh/StanfordBDHG/NAMS)
[![DOI](https://zenodo.org/badge/648881967.svg)](https://zenodo.org/badge/latestdoi/648881967)

This repository contains the Neurodevelopment Assessment and Monitoring System (NAMS).
It demonstrates using the [Spezi](https://github.com/StanfordSpezi/Spezi) framework and builds on top of the [Stanford Spezi Template Application](https://github.com/StanfordSpezi/SpeziTemplateApplication).


## Application Structure

The Neurodevelopment Assessment and Monitoring System (NAMS) uses a modularized structure using the [Spezi modules](https://swiftpackageindex.com/StanfordSpezi) enabled by the Swift Package Manager.

The application uses [HL7 FHIR](https://www.hl7.org/fhir/) and the Spezi [`FHIR` module](https://github.com/StanfordSpezi/SpeziFHIR) to provide a common standard to encode data gathered by the application as defined in the Spezi [`Standard`](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/standard) found in the application.
You can learn more about the Spezi standards-based software architecture in the [Spezi documentation](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi).

### Muse SDK

The project supports Muse EEG Headbands to collect EEG recordings.

The Muse SDK is closed-source and, therefore, not part of this repository.
For more information, refer to the [Muse SDK FAQ](https://choosemuse.my.site.com/s/article/Muse-Software-Development-Kit-SDK-FAQs?language=en_US) page.
If you have access, you may need to fetch the git submodule by running the following command:
```shell
git submodule update --init
```

The Xcode project configures two targets:
* `NAMS`: This target uses a Mock Device Layer and does not include the Muse SDK. It is useful for demonstration and testing purposes. 
* `NAMS Muse` This target includes the Muse SDK. It does not build on the iOS Simulator.

## Build and Run the Application

You can build and run the application using [Xcode](https://developer.apple.com/xcode/) by opening up the **NAMS.xcodeproj**.

The application provides a [Firebase Firestore](https://firebase.google.com/docs/firestore)-based data upload and [Firebase Authentication](https://firebase.google.com/docs/auth) login & sign-up.
It is required to have the [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite) to be up and running to use these features to build and test the application locally. Please follow the [installation instructions](https://firebase.google.com/docs/emulator-suite/install_and_configure). 

You do not have to make any modifications to the Firebase configuration, login into the `firebase` CLI using your Google account, or create a project in firebase to run, build, and test the application!

Startup the [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite) using
```
$ firebase emulators:start
```

After the emulators have started up, you can run the application in your simulator to build, test, and run the application.

The application includes the following feature flags that can be configured in the [scheme editor in Xcode](https://help.apple.com/xcode/mac/11.4/index.html?localePath=en.lproj#/dev0bee46f46) and selecting the **NAMS** scheme, the **Run** configuration, and to switch to the **Arguments** tab to add, enable, disable, or remove the following arguments passed on launch:
- ``--skipOnboarding``: Skips the onboarding flow to enable easier development of features in the application and to allow UI tests to skip the onboarding flow.
- ``--showOnboarding``: Always show the onboarding when the application is launched. Makes it easy to modify and test the onboarding flow without the need to manually remove the application or reset the simulator.
- ``--disableFirebase``: Disables the Firebase interactions, including the login/sign-up step and the Firebase Firestore upload.
- ``--useFirebaseEmulator``: Defines if the application should connect to the local firebase emulator. Always set to true when using the iOS simulator.
- ``--testSchedule``: Adds a test task to the schedule at the current time.
- ``--render-accessibility-actions``: Custom accessibility actions cannot be reliably tested. This flag ensures custom accessibility actions are rendered as UI elements.


## Continuous Delivery Workflows

The Neurodevelopment Assessment and Monitoring System (NAMS) application includes continuous integration (CI) and continuous delivery (CD) setup.
- Automatically build and test the application on every pull request before deploying it.
- An automated setup to deploy the application to TestFlight every time there is a new commit on the repository's main branch.
- Ensure a coherent code style by checking the conformance to the SwiftLint rules defined in `.swiftlint.yml` on every pull request and commit.
- Ensure conformance to the [REUSE Specification]() to property license the application and all related code.

Please refer to the [Stanford Biodesign Digital Health Neurodevelopment Assessment and Monitoring System (NAMS)](https://github.com/StanfordBDHG/NAMS) and the [ContinuousDelivery Example by Paul Schmiedmayer](https://github.com/PSchmiedmayer/ContinousDelivery) for more background about the CI and CD setup for the Neurodevelopment Assessment and Monitoring System (NAMS).


## Contributors & License

This project is based on [ContinuousDelivery Example by Paul Schmiedmayer](https://github.com/PSchmiedmayer/ContinousDelivery), and the [Neurodevelopment Assessment and Monitoring System (NAMS)](https://github.com/StanfordBDHG/NAMS) provided using the MIT license.
You can find a list of contributors in the `CONTRIBUTORS.md` file.

The Neurodevelopment Assessment and Monitoring System (NAMS) and the Spezi framework are licensed under the MIT license.
