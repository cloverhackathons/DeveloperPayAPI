# Swift Developer Pay API Example

## Requirements

- JDK 8  
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

**Open `DeveloperPayAPI/java` in IntelliJ.**

Select `Main.java` and edit the config variables to include your own test Merchant ID and the OAuth token you created.

Make sure project SDK, language level and JRE are set to Java 8 (because of `javax.xml.bind.DatatypeConverter`).

## Troubleshooting

#### Remember to set your accessToken with PROCESS_CARDS permission on line 5
- Edit the variable `accessToken` with your access token. Read the following to learn more: https://docs.clover.com/clover-platform/docs/using-oauth-20

#### 401 Unauthorized
- Make sure you've enabled read/write permissions for your app in [Clover's developer dashboard](https://sandbox.dev.clover.com/developers). After enabling, uninstall and then re-install the app on your test merchant. Apps are only granted the permissions requested at the time of installation.

#### Other common HTTP status codes
- Read: https://medium.com/clover-platform-blog/troubleshooting-common-clover-rest-api-error-codes-9aaa8885373