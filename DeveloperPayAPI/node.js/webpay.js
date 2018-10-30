const fetch = require('node-fetch');
const crypto = require('crypto');

/******************************************************************************/
/****************************     Config Setup      ***************************/
/******************************************************************************/

const mId = 'MKCR771TCY301'; // Enter your merchant ID here.
const orderID = 'N3X9F54T8QCM4'; // Enter your order ID here.
const apiToken = '59cb3276-54de-fcb4-3c8b-c5e133689755'; // Enter your API Token here.

const targetEnv = 'https://apisandbox.dev.clover.com/v2/merchant';

// Below are some starting values for you to run it and see that it works.
const cardNumber = '4111111111111111';
const first6 = cardNumber.slice(0,6);
const last4 = cardNumber.slice(-4);
const expMonth = 1;
const expYear = 2019;
const cvv = '111';
const zip = '11111'
const amount = 100;
const taxAmount = 0;
const currency = 'usd';

/******************************************************************************/
/*********************     Developer Pay Example Code     *********************/
/******************************************************************************/


/************************** GET encryption info (pem) *************************/

// GET /v2/merchant/{mId}/pay/key to get the encryption info.
const url = targetEnv + mId + '/pay/key';

// request options
const options = {
  method: 'GET',
  headers: {
    Authorization: `Bearer ${apiToken}`
  }
}

// request and encrypting of credit card number
fetch(url, options)
  .then(res => res.json())
  .then(encryptionInfo => processEncryption(encryptionInfo))
  .catch(err => console.log(err));


/*************************** Card encryption logic ****************************/

// Encrypt card number and call postPayment, passing in encrypted card number
const processEncryption = encryptionInfo => {
    const prefix = encryptionInfo['prefix'];
    const pem = encryptionInfo['pem'];

    // create a cipher from the RSA key and use it to encrypt the card number, prepended with the prefix from GET /v2/merchant/{mId}/pay/key
    const encrypted = crypto.publicEncrypt(pem, Buffer(prefix + cardNumber));

    // Base64 encode the resulting encrypted data into a string to Clover as the 'cardEncrypted' property.
    const cardEncrypted = new Buffer(encrypted).toString('base64');
    // post the payment with encrypted card information
    postPayment(cardEncrypted);
}

/***************************** POST the payment *******************************/

// Post the payment with the encrypted card number and card information.
const postPayment = cardEncrypted => {
    // POST /v2/merchant/{mId}/pay to post payment
    const url = targetEnv + mId + '/pay';

    // request body
    const body = {
        orderId: orderID,
        taxAmount: taxAmount,
        zip: zip,
        expMonth: expMonth,
        cvv: cvv,
        amount: amount,
        currency: currency,
        last4: last4,
        expYear: expYear,
        first6: first6,
        cardEncrypted: cardEncrypted
    };

    // request options
    const options = {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${apiToken}`
        },
        body: JSON.stringify(body)
    }

    // request and logging of response
    fetch(url, options)
      .then(res => res.json())
      .then(data => console.log(data))
      .catch(err => console.log(err));
}
