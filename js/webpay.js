// import requests
// import json
// from Crypto.Cipher import PKCS1_OAEP
// from Crypto.PublicKey import RSA
// from base64 import b64encode
// ###############################################
// ########## BEGIN SCRIPT CONFIG SETUP ##########
// ###############################################
//
const merchantID = "CNKMYYVYGJHXJ"; // sandbox Test Merchant
const target_env = "https://apisandbox.dev.clover.com/v2/merchant/";
const orderID = "8GCADRD79S1DW";
const API_Token = "1decda79-717f-8ad5-a3d4-f4f6bb0d7ee0";
const amount = 1000;
const tipAmount = 0;
const taxAmount = 0;
const cardNumber = '4761739001010010';
const expMonth = 12;
const expYear = 2018;
const cvv = undefined;

console.log("hello!");
//
// ###############################################
// ########## END SCRIPT CONFIG SETUP ############
// ###############################################
//
const url = target_env + merchantID + '/pay/key?access_token=' + API_Token;
const url2 = "https://apisandbox.dev.clover.com/v3/merchants/SJ925JDCKKTJJ?access_token=7453d0cc-c57c-ab50-a37f-cd8a40e3741d";

let response = undefined;

// # GET to /v2/merchant/{mId}/pay/key To get the encryption information needed for the pay endpoint.
$.ajax({
  method: "GET",
  url: url,
  success: function(r) {
    response = r;
    console.log(response);
  },
  failure: function(err) {
    console.log("something went wrong:\n");
    console.log(err);
  }
});


// response = requests.get(url, headers = headers).json()
//
// modulus = long(response['modulus'])
// exponent = long(response['exponent'])
// prefix = str(response['prefix'])
//
// # construct an RSA public key using the modulus and exponent provided by GET /v2/merchant/{mId}/pay/key
// key = RSA.construct((modulus, exponent))
//
// # create a cipher from the RSA key and use it to encrypt the card number, prepended with the prefix from GET /v2/merchant/{mId}/pay/key
// cipher = PKCS1_OAEP.new(key)
// encrypted = cipher.encrypt(prefix + cardNumber)
//
// # Base64 encode the resulting encrypted data into a string to Clover as the 'cardEncrypted' property.
// cardEncrypted = b64encode(encrypted)
//
// # POST to /v2/merchant/{mId}/pay
// post_data = {
//     "orderId": orderID,
//     "currency": "usd",
//     "amount": amount,
//     "tipAmount": tipAmount,
//     "taxAmount": taxAmount,
//     "expMonth": expMonth,
//     "cvv": cvv,
//     "expYear": expYear,
//     "cardEncrypted": cardEncrypted,
//     "last4": cardNumber[-4:],
//     "first6": cardNumber[0:6]
// }
//
// posturl = target_env + merchantID + '/pay'
// postresponse = requests.post(
//     posturl,
//     headers = headers,
//     data= post_data
//     ).json()
//
// print json.dumps(postresponse)
