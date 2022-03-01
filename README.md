# biplus_radio

An application for listening BiPlus Radio

## Getting Started

Note for making build after checkout from git:

1. Open android/local.properties file and append the following lines:

    flutter.minSdkVersion=21
    flutter.targetSdkVersion=29
    flutter.compileSdkVersion=29
    flutter.buildMode=debug
    ndkVersion=21.3.6528147
    flutter.versionName=1.0.0
    flutter.versionCode=1

2. Get all dependencies by running the command below in terminal. Note that you have to navigate to the project folder:
   
    flutter pub get

3. Generate json serialization file (*.g.dart) using the following command:
   
   flutter pub run build_runner build --delete-conflicting-outputs watch

4. Run web app
    Run on local: 
   
    flutter run -d chrome --web-renderer html
    
    Run with open port for incoming connection:
   
    flutter run -d web-server --web-port 16500 --web-hostname 0.0.0.0 --web-renderer html

5. Deploy web app on server 
    - Navigate to project root folder
    - Run command: ** flutter build web --web-renderer html **
    - Copy folder build/web to server
    - Navigate to folder build/web copy from above step on server
    - Run command: ** nohup python -m http.server 16500 &> biplus_radio_web.log & ** 
      (Note that web will be running on port 16500)

6. To generate localization file run below command:

   flutter gen-l10n