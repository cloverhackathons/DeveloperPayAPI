# Python Developer Pay API Example

## Requirements

- Python 3.7.3 (backwards compatible with 2.7)  
- pip  
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

## Setting Up the Script

Install the dependencies by executing the following command from the terminal:

`pip install -r requirements.txt`

Open `webpay.py` and edit the script config to include your own test Merchant ID, an Order ID belonging that Merchant, and the OAuth token you created.

## Running the Script

To run the script, execute the following command from the terminal:

`python webpay.py`
