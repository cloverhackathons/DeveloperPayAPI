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
cd DeveloperPayAPI/swift
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

**Open `DeveloperPay.xcworkspace` in Xcode.**

Once `DeveloperPay.xcworkspace` is open, select `DeveloperPay.playground` and edit the config variables to include your own test Merchant ID, an Order ID belonging to that Merchant, and the OAuth token you created.

## Running the Script

1. Make sure you've opened and are in `DeveloperPay.xcworkspace` (this ensures the CocoaPods dependencies are recognized).
2. Go to **Product > Build** (⌘ + B) to build the project.
3. Select `DeveloperPay.playground` in the left-hand Navigator menu.
4. Click **Execute Playground**.

## Troubleshooting

#### No such module 'BigInt'
- Make sure to follow the steps above in **Setting Up the Script**. This usually means the project or playground was opened and _not_ `DeveloperPay.xcworkspace`.

#### gem: Command not found
- In a Terminal window, type `which gem` to verify that gem is installed and where. You may have to modify `$PATH` to include gem or you may have to [install gem](https://rubygems.org/pages/download).

#### Remember to set your accessToken with PROCESS_CARDS permission on line 5
- Edit the variable `accessToken` with your access token. Read the following to learn more: https://docs.clover.com/clover-platform/docs/using-oauth-20

#### 401 Unauthorized
- Make sure you've enabled read/write permissions for your app in [Clover's developer dashboard](https://sandbox.dev.clover.com/developers). After enabling, uninstall and then re-install the app on your test merchant. Apps are only granted the permissions requested at the time of installation.

#### Other common HTTP status codes
- Read: https://medium.com/clover-platform-blog/troubleshooting-common-clover-rest-api-error-codes-9aaa8885373