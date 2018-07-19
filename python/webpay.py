import requests
import json
from Crypto.Cipher import PKCS1_OAEP
from Crypto.PublicKey import RSA
from base64 import b64encode

###############################################
########## BEGIN SCRIPT CONFIG SETUP ##########
###############################################

merchantId = "BP71B7BE2BPZ4"  # TODO: Replace with your merchantId.
orderId = "CM70NHZ7VW1DY"  # TODO: Replace with an orderId that you created.
access_token = ""  # TODO: Replace with your access_token with PROCESS_CARDS permission.

target_env = "https://sandbox.dev.clover.com"
v2_merchant_path = "/v2/merchant/"

amount = 1000
tipAmount = 0
taxAmount = 0
cardNumber = "6011361000006668"
expMonth = 12
expYear = 2018
cvv = 123
zip_code = 94085

###############################################
########## END SCRIPT CONFIG SETUP ############
###############################################

# GET /v2/merchant/{mId}/pay/key for the encryption information needed for
# the pay endpoint.
url = target_env + v2_merchant_path + merchantId + "/pay/key"
headers = {"Authorization": "Bearer " + access_token}

print "Requesting GET " + url
response = requests.get(url, headers=headers)

if response.status_code != requests.codes.ok:
    print "Response was not 200 OK!"
    print """Read "Troubleshooting common Clover REST API error codes" at
https://medium.com/clover-platform-blog/troubleshooting-common-clover-rest-api-error-codes-9aaa8885373"""
    response.raise_for_status()

try:
    response = response.json()
except ValueError, e:
    print response
    raise

print "Response:"
print json.dumps(response, indent=4)

try:
    modulus = long(response['modulus'])
    exponent = long(response['exponent'])
    prefix = str(response['prefix'])
except KeyError, e:
    print response
    raise

# Construct an RSA public key using the modulus and exponent from GET
# /v2/merchant/{mId}/pay/key.
print "Creating public key..."
key = RSA.construct((modulus, exponent))

# Create a cipher from the RSA key and use it to encrypt the card number
# prepended with the prefix from GET /v2/merchant/{mId}/pay/key.
print "Encrypting card number..."
cipher = PKCS1_OAEP.new(key)
encrypted = cipher.encrypt(prefix + cardNumber)

# Base64 encode the resulting encrypted data into a string.
cardEncrypted = b64encode(encrypted)

# POST to /v2/merchant/{mId}/pay.
post_url = target_env + v2_merchant_path + merchantId + '/pay'
headers = {"Authorization": "Bearer " + access_token}
post_data = {
    "orderId": orderId,
    "currency": "usd",
    "amount": amount,
    "tipAmount": tipAmount,
    "taxAmount": taxAmount,
    "expMonth": expMonth,
    "expYear": expYear,
    "cvv": cvv,
    "cardEncrypted": cardEncrypted,
    "last4": cardNumber[-4:],
    "first6": cardNumber[0:6],
    "zip": zip_code
}

print "Requesting POST " + post_url
post_response = requests.post(post_url, headers=headers, data=post_data)

if post_response.status_code != requests.codes.ok:
    print "Response was not 200 OK!"
    response.raise_for_status()

try:
    post_response = post_response.json()
except ValueError, e:
    raise

print "Response:"
print json.dumps(post_response, indent=4)
