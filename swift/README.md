# Swift Developer Pay API Example

## Requirements

- Mac OSX 10.14.3
- Xcode 10.2.1  
- CocoaPods 1.5.3
- CocoaPods Downloader 1.2.0 
- [Clover Sandbox developer account](https://sandbox.dev.clover.com/developers)

## Prerequisites

Log into your [Clover Sandbox developer account](https://sandbox.dev.clover.com/developers) and create an app with the following [permissions](https://docs.clover.com/clover-platform/docs/permissions):
* Merchant Read
* Orders Read
* Orders Write
* Payments Read
* Payments Write
* Process Credit Cards

Install the app to your test merchant and [create an OAuth token](https://docs.clover.com/clover-platform/docs/using-oauth-20).

## Clone this repo

```
git clone https://github.com/cloverhackathons/DeveloperPayAPI.git
```

## Setting Up the Script

Navigate to the Swift example directory:

```
cd DeveloperPayAPI/Swift
```

Verify that you have CocoaPods >= 1.5.3 && CocoaPods Downloader >= 1.2.0 installed:

```
gem list cocoapods
```

If you're missing either of those two, install with the following commands:

```
sudo gem install cocoapods -v 1.5.3
sudo gem install cocoapods-downloader -v 1.2.0
```

Install the dependencies:

```
pod install
```

Open `DeveloperPay.xcworkspace` in Xcode.

Once `DeveloperPay.xcworkspace` is open, select `DeveloperPay.playground` and edit the config variables to include your own test Merchant ID, an Order ID belonging to that Merchant, and the OAuth token you created.

## Running the Script

To run the script, just execute the `DeveloperPay.playground` in Xcode but make sure you do so in `DeveloperPay.xcworkspace` so the CocoaPods dependencies are recognized.