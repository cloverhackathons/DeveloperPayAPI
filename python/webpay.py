import requests
import json
from Crypto.Cipher import PKCS1_OAEP
from Crypto.PublicKey import RSA
from base64 import b64encode
###############################################
########## BEGIN SCRIPT CONFIG SETUP ##########
###############################################

merchantID = "CNKMYYVYGJHXJ" # TODO: replace with your merchantID
target_env = "https://sandbox.dev.clover.com/v2/merchant/"
orderID = "8GCADRD79S1DW" # TODO: replace with an orderID you generate
API_Token = "your_access_token" # TODO: replace with your access_token
amount = 1000
tipAmount = 0
taxAmount = 0
cardNumber = '4761739001010010'
expMonth = 12
expYear = 2018
CVV = None

###############################################
########## END SCRIPT CONFIG SETUP ############
###############################################

# GET to /v2/merchant/{mId}/pay/key To get the encryption information needed for the pay endpoint.
url = target_env + merchantID + '/pay/key'
headers = {"Authorization": "Bearer " + API_Token}
response = requests.get(url, headers = headers).json()

modulus = long(response['modulus'])
exponent = long(response['exponent'])
prefix = str(response['prefix'])

print str(modulus)
print str(exponent)
print prefix

# construct an RSA public key using the modulus and exponent provided by GET /v2/merchant/{mId}/pay/key
key = RSA.construct((modulus, exponent))

# create a cipher from the RSA key and use it to encrypt the card number, prepended with the prefix from GET /v2/merchant/{mId}/pay/key
cipher = PKCS1_OAEP.new(key)
encrypted = cipher.encrypt(prefix + cardNumber)

# Base64 encode the resulting encrypted data into a string to Clover as the 'cardEncrypted' property.
cardEncrypted = b64encode(encrypted)

# POST to /v2/merchant/{mId}/pay
post_data = {
    "orderId": orderID,
    "currency": "usd",
    "amount": amount,
    "tipAmount": tipAmount,
    "taxAmount": taxAmount,
    "expMonth": expMonth,
    "cvv": CVV,
    "expYear": expYear,
    "cardEncrypted": cardEncrypted,
    "last4": cardNumber[-4:],
    "first6": cardNumber[0:6]
}

posturl = target_env + merchantID + '/pay'
postresponse = requests.post(
    posturl,
    headers = headers,
    data= post_data
    ).json()

print json.dumps(postresponse)
