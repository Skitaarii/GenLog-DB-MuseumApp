# Museum App 
This project is done during our Software engineering and DataBase courses that we're following in the 2nd year of Computer Science Bachelor cursus from the University Of Applied Science of Sion, Valais, Switzerland. 
## Description 
### Context 
A museum want a mobile-friendly app on which the *visitors* can scan an exhibit's QRCode, giving all the informations related to it. Furthermore, visitors should have access to thematic itineraries, scoring 1-5 stars per exhibits, add them to favorite and give a feedback. Their session has to be anonymized.

The *admin* (Editors and curators) should have their own app with editing exhibits and having a dashboard for analytics, respectively.

This is a mobile-friendly app made on Flutter that works even with unreliable connectivity. There is 3 audiences simultaneously :
1) **Visitor** : A lightweight app, giving details about museum's exhibits by scanning their corresponding QRCode ;
2) **Editors** :  Edit, update, add new exhibit ;
3) **Curator** : Analytics revealing visitor flows, dwell time, exhibit engagment and so on.

## Docker and Database

### How to start DB:
1) open docker desktop
2) Run docker compose up -d

### If you want to recompose docker:
1) docker compose down -v !!do not do this if you do not want to delete ALL POSTGRES DATA
2) docker compose up -d

### Start/stop docker:
- stop: docker compose stop
- start: docker compose start


## Prerequisites

Before running the project, make sure you have installed and configured:

* [Flutter](https://flutter.dev/docs/get-started/install) and added it to your `PATH`.
* JDK with `JAVA_HOME` set.
* Android SDK at `C:[YOUR PATH]\platformTools\AndroidSDK`.
* ADB (`platform-tools`) accessible via `PATH`.
* PostgreSQL DB works perfectly.

---

## Environment Variables

Add to your PATH or verify:

```powershell
$env:ANDROID_SDK_ROOT="C:[YOUR PATH]\platformTools\AndroidSDK"
$env:PATH += ";C:[YOUR PATH]\platformTools\AndroidSDK\platform-tools"
```

---

## Android SDK Components

Accept licenses:

```powershell
sdkmanager --licenses
```

Install required packages:

```powershell
sdkmanager "platform-tools" "cmdline-tools;latest" "system-images;android-33;google_apis;x86_64"
```

---

## Create and Launch an AVD

Create an Android Virtual Device (AVD) using Android Studio or command line.
Example for Pixel 6 API 33:

```powershell
cd C:[YOUR PATH]\platformTools\AndroidSDK\emulator
.\emulator.exe -avd Pixel_6_API_33
```

Check the emulator is recognized:

```powershell
adb devices
```

> If `adb` is not recognized, make sure `platform-tools` is in your `PATH`.

---

## Prepare the Flutter Project

Navigate to the project folder:

```powershell
cd C:[YOUR PATH]\GenLog-DB-MuseumApp\trying_flutter
```

Install dependencies:

```powershell
flutter pub get
```

> Ensure DB settings are correct in `main.dart` if using PostgreSQL.

---

## Run the Application

With the emulator already running:

```powershell
flutter run
```

* Hot reload: `r`
* Hot restart: `R`

---

## Checks

* APK builds and installs on the emulator.
* App launches without connection errors.
* Check logs for correct operation




