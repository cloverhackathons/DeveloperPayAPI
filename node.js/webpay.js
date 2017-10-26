const crypto = require('crypto');
const request = require('request');

var merchantID = ''; // Enter your merchant ID here.
var orderID = ''; // Enter your order ID here.
var apiToken = ''; // Enter your API Token here.

var targetEnv = 'https://sandbox.dev.clover.com/v2/merchant/';

var amount = 100;
var tipAmount = 0;
var taxAmount = 0;
var cardNumber = '6011361000006668';
var expMonth = 12;
var expYear = 2018;
var cvv = 123;

//###############################################
//########## END SCRIPT CONFIG SETUP ############
//###############################################

// GET to /v2/merchant/{mId}/pay/key To get the encryption information needed for the pay endpoint.
var url = targetEnv + merchantID + '/pay/key';
var options = {
    url: url,
    method: 'GET',
    headers: {
        Authorization: 'Bearer ' + apiToken
    }
};

request(options, function(error, response, body) {
    if (!error && response.statusCode === 200) {
        processEncryption(JSON.parse(body));
    }
});

// Process the encryption information received by the pay endpoint.
function processEncryption(jsonResponse) {
    var prefix = jsonResponse['prefix'];
    var pem = jsonResponse['pem'];

    // create a cipher from the RSA key and use it to encrypt the card number, prepended with the prefix from GET /v2/merchant/{mId}/pay/key
    var encrypted = crypto.publicEncrypt(pem, Buffer(prefix + cardNumber));

    // Base64 encode the resulting encrypted data into a string to Clover as the 'cardEncrypted' property.
    var cardEncrypted = new Buffer(encrypted).toString('base64');

    postPayment(cardEncrypted);
}

// Post the payment to the pay endpoint with the encrypted card information.
function postPayment(cardEncrypted) {
    // POST to /v2/merchant/{mId}/pay
    var posturl = targetEnv + merchantID + '/pay';
    var postData = {
        'orderId': orderID,
        'currency': 'usd',
        'amount': amount,
        'tipAmount': tipAmount,
        'taxAmount': taxAmount,
        'expMonth': expMonth,
        'cvv': cvv,
        'expYear': expYear,
        'cardEncrypted': cardEncrypted,
        'last4': cardNumber.slice(-4),
        'first6': cardNumber.slice(0,6),
        'streetAddress': '123 Fake street',
        'zip': '94080'
    };

    var options = {
        url: posturl,
        method: 'POST',
        headers: {
            'Authorization': 'Bearer ' + apiToken,
        },
        json: postData
    };

    request(options, function(error, response, body) {
        if (!error && response.statusCode === 200) {
            console.log(response);
        }
    });
}