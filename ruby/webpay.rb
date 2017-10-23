require 'net/http'
require 'openssl'
require 'json'
require 'base64'

###############################################
########## BEGIN SCRIPT CONFIG SETUP ##########
###############################################

merchant_id = "CNKMYYVYGJHXJ" # sandbox Test Merchant
target_env = "https://sandbox.dev.clover.com/v2/merchant/"
orderID = "8GCADRD79S1DW"
api_token = "1decda79-717f-8ad5-a3d4-f4f6bb0d7ee0"
amount = 1000
tip_amount = 0
tax_amount = 0
card_number = '4761739001010010'
first6 = '476173'
last4 = '0010'
exp_month = 12
exp_year = 2018
cvv = '123'

###############################################
########## END SCRIPT CONFIG SETUP ############
###############################################


# GET to /v2/merchant/{mId}/pay/key To get the encryption information needed for the pay endpoint.
uri = URI("#{target_env + merchant_id}/pay/key?access_token=#{api_token}")
response = Net::HTTP.get(uri)
json_response = JSON.parse(response)
modulus = json_response["modulus"].to_i
exponent = json_response["exponent"].to_i
prefix = json_response["prefix"]

# construct an RSA public key using the modulus and exponent provided by GET /v2/merchant/{mId}/pay/key
rsa = OpenSSL::PKey::RSA.new.tap do |rsa|
  rsa.e = OpenSSL::BN.new(exponent)
  rsa.n = OpenSSL::BN.new(modulus)
end

# create a cipher from the RSA key and use it to encrypt the card number, prepended with the prefix from GET /v2/merchant/{mId}/pay/key
encrypted = rsa.public_encrypt(prefix + card_number, OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)

# Base64 encode the resulting encrypted data into a string to Clover as the 'cardEncrypted' property.
card_encrypted = Base64.encode64(encrypted)

# POST to /v2/merchant/{mId}/pay
post_data = {
  "orderId": orderID, 
  "tipAmount": tip_amount,
  "taxAmount": tax_amount, 
  "expMonth": exp_month, 
  "cvv": cvv, 
  "amount": amount, 
  "currency": "usd", 
  "last4": last4, 
  "expYear": exp_year, 
  "first6": first6, 
  "cardEncrypted": card_encrypted
}
uri = URI("#{target_env + merchant_id}/pay?access_token=#{api_token}")
response = Net::HTTP.post_form(uri, post_data)
puts response.body