# Phonegap + Ember example

## phonegap

[Phonegap CLI](https://www.npmjs.com/package/phonegap) is just a wrapper over [cordova](https://www.npmjs.com/package/cordova), most commands just call the cordova equivalent. In some cases it can be more useful to call the cordova command directly (e.g. if you have errors) as it may give more output (phonegap silences most of cordova output). E.g. for building Android I would usually run `./node_modules/phonegap/node_modules/.bin/cordova run android --device`. I could have `npm installed cordova` but at least this way I was assuring I was building with the same version I was using for phonegap commands.

## Ember

This information was formed when running Ember 1.13

We disabled Ember URL routes (`locationType: 'none'`). I think there was an important reason but I don't recall. The user can't see/use URLs in phonegap anyway.

It is important to disable the `baseUrl` field in the `config/environment.js` file, this will insert a `<base/>` tag that causes absolute paths instead of relative paths which are required for apps running in a webview.

All urls for assets should be relative to the `www` directory

We build the app into the `www` directory. **NOTE** this wipes the `www` folder every build. We store assets in an `assets` folder, the content of which gets copied into the `www` folder on build.

The supplied package.json doesn't include an ember build. TODO: add a basic ember app starting point.

## iOS, xcode, simulation

Initially add an iOS build using `phonegap platform add ios`. This creates a project which you can open in xcode at `platforms/ios/`. You can also then build/run the app in simulator via command-line (see package.json below).

I think you may need a certificate from Apple before being able to even run the simulator. To do so I think you open xcode and attempt to run it and it will ask you to log in to create a certificate. Your Apple account will need to be added to our Apple developer team.

## Running / Development

The `package.json` has a number of useful commands set up

* `npm start` runs as an ember server for you to develop in-browser (without cordova plugins)
* `npm run ios` builds a release version and runs it on the iOS simulator (my most used command when testing the app). You can run the iOS directly on your plugged-in phone using xcode (there may be a way via command-line, haven't tried).
* `phonegap run android [--device|--emulator] [--release] [--nobuild]` build/run Android. You can plug in a device to run it on your phone.

Ember build happens on cordova build hook (see `hooks/before_prepare`). This means any time you build iOS or Android locally it will run an ember build. The development/production build environment will match up with the cordova development/release environment.

## Plugins

Plugins are listed in config.xml

Your local build and simulator don't use the plugins listed in config.xml. Locally you have to add plugins using e.g. `phonegap plugin add cordova-plugin-console`

Any new plugins will also need to be added to the config.xml. You can use the `-S` flag, however the format it writes in the config.xml file doesn't seem to match what build.phonegap uses. I used the -S just to copy the exact version number, then just added the plugin line the same as the others in config.xml.

TODO: list useful plugins. There is a list in config.xml that have been used in previous projects.

## Build phone app

Before build, update the version in `config.xml` (2nd line). We have used patch versions for development builds, and minor versions for releases to app/play stores. Please include just the version bump in the commit, and the version in the commit message e.g. 'Update version v1.1.26'. After committing the version, please make a git tag e.g. `git tag -a v1.1.26` and enter a list of changes since previous version.

Build is done with with PhoneGap Build - https://build.phonegap.com/apps

IMPORTANT: When you push a build to PhoneGap you're pushing a build version of the ember app and all of it's required assets. It only uploads your config.xml and www folder (I think that's about it). So You'll need to ensure you've done a production build into the www folder before running `remote build`.

#### iOS

You can push the latest changes directly to PhoneGap using `phonegap remote build ios`. NOTE: this will upload the current state of your www folder to PhoneGap. You must have the latest build locally before building remote e.g. `npm run build` or `npm run ios:build`.

It should automatically build the app (there's a button to rebuild if it didn't work). If using [TestFairy](https://app.testfairy.com/) you can download the iOS .ipa file from build.phonegap.com and upload it to TestFairy, and send out the new version to testers.

You'll need to have set up the build.phonegap with a development certificate and key, see "Add new iOS device" below.

#### Android

Similarly to iOS you can `phonegap remote build android`. I don't exactly know how it's different, because pushing 1 of them builds both on phonegap anyway, perhaps you only need to remote build 1 of them? To sign the app I created a keystore as defined [here](https://developer.android.com/tools/publishing/app-signing.html) and uploaded to phonegap.

### Add new iOS device

1. Add a person's email to TestFairy. This will send them an invite that they will need to open and accept on their iThing.

2. In TestFairy, go to testers, and export, choosing only the new users. Or you can just copy the Apple device id without exporting.

3. If you go to https://developer.apple.com/account/ios/device/deviceCreate.action you can upload the export file under the `Register Multiple Devices` section, or just manually insert devices (it complains if any of the devices already exist (facepalm)).

4. Then go to https://developer.apple.com/account/ios/profile/profileList.action?type=limited and add the new devices to the provisioning profile for the app (E.g. "Media Suite Test Group" profile).

5. Export the profile, and import as a new key in PhoneGap Build (https://build.phonegap.com/apps). You'll need a certificate .p12 file, if you don't have one:
- From the apple page above, select certificates, download yours or create your own.
- Import the certificate to Key Chain.
- From Key Chain select the imported key and export as p12 and set a password for it (you'll need to type this into phonegap). Upload this as your certificate.
After creating a new key on Phonegap with a certificate and profile, click the lock to unlock it and type the password for your exported p12. Sometimes on submission the password box would submit but the lock wouldn't unlock, in this case refreshing the page usually showed that it was unlocked.

Build and deploy again as above

### App Store

Go to https://build.phonegap.com/apps and select the App Store Distribution key for the iOS version, then run `npm run ios:build` and `npm run ios:deploy`

Then pull down the generated .ipa and upload to the App Store using Application Loader

TODO: add info about creating new version of the app in iTunes Connect here...

#### Updating the profile/cert

There is a Provisioning Profile and Certificate set specifically for app store distribution here: https://developer.apple.com/account/ios/certificate/certificateList.action
Do step 5 above, but make sure to download and create a .p12 from the **distribution** certificate, not a dev one.
