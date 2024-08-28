
![ic_launcher](https://github.com/user-attachments/assets/9217c595-49d0-426e-9ace-eff1934247c4) 

# Visit Recorder


## Overview

Visit Recorder is a Flutter-based mobile application designed to help users log and automatically track their visit duration. Whether you're managing client visits, tracking fieldwork, or simply keeping a personal record of places you’ve been, Visit Recorder offers a simple and intuitive interface to make this process easy and efficient.

## Features

- **Easy Location Logging**: Record your visits with a single tap, automatically capturing the date, time, and location.
- **Automatic Duration**: The app deploys a foregrund service that keeps track of the time when you are near your visiting place.

## Installation
The app uses GSheets api, you will have to create a service account and set it's credentials at creds.dart file, example is given as creds.dart.example

### Prerequisites

- Flutter 3.0.0 or higher
- Dart 2.18.0 or higher
- Android Studio or Visual Studio Code
- Flutter Background Service
- GPS location and geolocator package

## Usage

**Logging a Visit**: Open the app, fillup the visit place and tap the “Submit” button. The app will (automatically redirect you to profile page if you have not filled up your details) record your location, date, and time.

# App view:

![Screenshot_1724825148](https://github.com/user-attachments/assets/5204e835-2650-4d26-b4f7-2364daed759b)
![Screenshot_1724825364](https://github.com/user-attachments/assets/f05d3b51-424a-4d52-8b37-c7a7952251d3)

