import BigInt


// Configuration variables
let accessToken = ""
let merchantId = ""
let orderId = ""

// Clover's Sandbox environment
let targetEnv = "https://apisandbox.dev.clover.com"
let v2MerchantPath = "/v2/merchant/"

// Example values
let amount = 1000
let tipAmount = 0
let taxAmount = 0
let cardNumber = "6011361000006668"
let expMonth = 12
let expYear = 2018
let cvv = 123
let zipCode = 94085

// Helper function to compute the length field of a DER type: https://docs.microsoft.com/en-us/windows/desktop/SecCertEnroll/about-der-encoding-of-asn-1-types
func lengthField(of valueField: [UInt8]) -> [UInt8] {
    var count = valueField.count
    
    if count < 128 {
        return [UInt8(count)]
    }
    
    let lengthBytesCount = Int((log2(Double(count)) / 8) + 1)
    let firstLengthFieldByte = UInt8(128 + lengthBytesCount)
    var lengthField: [UInt8] = []
    
    for _ in 0..<lengthBytesCount {
        let lengthByte = UInt8(count & 0xff)
        lengthField.insert(lengthByte, at: 0)
        count = count >> 8
    }
    
    lengthField.insert(firstLengthFieldByte, at: 0)
    
    return lengthField
}

// Helper function to encode modulus and exponent into DER INTEGERs
func encodeIntArray(intArray: [UInt8]) -> [UInt8] {
    var encodedIntArray: [UInt8] = []
    
    encodedIntArray.append(0x02)
    encodedIntArray.append(contentsOf: lengthField(of: intArray))
    encodedIntArray.append(contentsOf: intArray)
    
    return encodedIntArray
}

// Helper function to combine the two DER Integers into a DER SEQUENCE
func createSequence(exponent: [UInt8]?, modulus: [UInt8]?) -> [UInt8] {
    var sequenceEncoded: [UInt8] = []
    
    if modulus != nil && exponent != nil {
        sequenceEncoded.append(0x30)
        sequenceEncoded.append(contentsOf: lengthField(of: (modulus! + exponent!)))
        sequenceEncoded.append(contentsOf: (modulus! + exponent!))
    }
    
    return sequenceEncoded
}

// Create SecKey from DER SEQUENCE
func createSecKey(sequence: [UInt8], modulusCount: Int) -> SecKey {
    let keyData = Data(_: sequence)
    
    // RSA key size is the number of bits of the modulus
    let keySize = (modulusCount * 8)
    
    let attributes: [String: Any] = [
        kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
        kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
        kSecAttrKeySizeInBits as String: keySize
    ]
    
    let publicKey = SecKeyCreateWithData(keyData as CFData, attributes as CFDictionary, nil)
    
    return publicKey!
}

// Encrypt Credit Card data with SecKey
func encryptCardData(prefix: String, cardNumber: String, sequence: [UInt8], publicKey: SecKey) -> String? {
    let data = (prefix + cardNumber).data(using: .utf8)
    let algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA1
    
    guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
        print("Something went wrong when generating the public key")
        return nil
    }
    
    guard let cipherText = SecKeyCreateEncryptedData(publicKey, algorithm, data! as CFData, nil) else {
        print("Something went wrong when encrypting the credit card data")
        return nil
    }
    
    let encryptedData = cipherText as Data
    let encryptedString = encryptedData.base64EncodedString(options: [])
    
    return encryptedString
}

// Helper function to parse the response JSON object
func parseResponseJSON(responseJSON: [String: Any]) -> ([UInt8], [UInt8], String, Int)? {
    var exponentEncoded: [UInt8]? = nil
    var modulusArray: [UInt8]? = nil
    var modulusEncoded: [UInt8]? = nil
    
    // Convert modulus and exponent from base10 to BigUInt: https://github.com/attaswift/BigInt
    guard let exponent = BigUInt(responseJSON["exponent"] as! String) else {
        return nil
    }
    guard let modulus = BigUInt(responseJSON["modulus"] as! String) else {
        return nil
    }
    guard let prefix = responseJSON["prefix"] as? String else {
        return nil
    }
    print("exponent:", exponent, "\nmodulus:", modulus, "\nprefix:", prefix, "\n")
    
    // Convert modulus and exponent from BigUInt into unsigned big-endian octet representation
    exponentEncoded = encodeIntArray(intArray: Array(exponent.serialize()))
    if modulusArray == nil {
        modulusArray = Array(modulus.serialize())
        // Prefix modulus with 0x00 to indicate that it is a non-negative number: https://msdn.microsoft.com/en-us/library/windows/desktop/bb540806(v=vs.85).aspx
        modulusArray!.insert(0x00, at: 0)
    }
    modulusEncoded = encodeIntArray(intArray: modulusArray!)
    
    return (exponentEncoded!, modulusEncoded!, prefix, modulusArray!.count)
}

// POST to /v2/merchant/{mId}/pay
func postPayment(cardEncrypted: String) {
    let url = targetEnv + v2MerchantPath + merchantId + "/pay"
    print("POST Request: " + url + "\n")
    
    let JSON: [String: Any] = [
        "orderId": orderId,
        "currency": "usd",
        "amount": amount,
        "tipAmount": tipAmount,
        "taxAmount": taxAmount,
        "expMonth": expMonth,
        "expYear": expYear,
        "cvv": cvv,
        "cardEncrypted": cardEncrypted,
        "last4": cardNumber.suffix(4),
        "first6": cardNumber.prefix(6),
        "zip": zipCode
    ]
    let JSONData = try? JSONSerialization.data(withJSONObject: JSON)
    
    var request = URLRequest(url: URL(string: url)!)
    request.httpMethod = "POST"
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
    request.httpBody = JSONData
    
    let asyncTask = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            print(error?.localizedDescription ?? "No data")
            return
        }
        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
        if let responseJSON = responseJSON as? [String: Any] {
            print("POST Response: \n", responseJSON)
        }
    }
    
    asyncTask.resume()
}

// GET /v2/merchant/{mId}/pay/key for the encryption information needed for the pay endpoint
func getEncryptionInfo(finished: @escaping ((_ responseJSON: [String: Any]) -> Void)) {
    let url = targetEnv + v2MerchantPath + merchantId + "/pay/key"
    print("Authorization: Bearer " + accessToken + "\n")
    print("GET Request: " + url + "\n")
    
    var request = URLRequest(url: URL(string: url)!)
    request.httpMethod = "GET"
    request.addValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
    
    let asyncTask = URLSession.shared.dataTask(with: request) { data, response, error in
        print("GET Response: \n")
        guard let data = data, error == nil else {
            print(error?.localizedDescription ?? "No data")
            return
        }
        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                if let responseJSON = responseJSON as? [String: Any] {
                    finished(responseJSON)
                }
            } else {
                print("Status", httpResponse.statusCode, "— Read 'Troubleshooting common Clover REST API error codes' at https://medium.com/clover-platform-blog/troubleshooting-common-clover-rest-api-error-codes-9aaa8885373")
            }
        }
    }
    
    asyncTask.resume()
}

enum ConfigError: Error {
    case emptyAccesToken
    case emptyMerchantId
    case emptyOrderId
}

// Make sure configuration variables are set before proceeding
func main() throws {
    if accessToken.isEmpty {
        throw ConfigError.emptyAccesToken
    } else if merchantId.isEmpty {
        throw ConfigError.emptyMerchantId
    } else if orderId.isEmpty {
        throw ConfigError.emptyOrderId
    } else {
        getEncryptionInfo(finished: { responseJSON in
            let (exponent, modulus, prefix, modulusCount) = (parseResponseJSON(responseJSON: responseJSON))!
            let sequence = createSequence(exponent: exponent, modulus: modulus)
            let publicKey: SecKey = createSecKey(sequence: sequence, modulusCount: modulusCount)
            if let encryptedData: String = encryptCardData(prefix: prefix, cardNumber: cardNumber, sequence: sequence, publicKey: publicKey) {
                postPayment(cardEncrypted: encryptedData)
            }
        })
    }
}

do {
    try main()
} catch ConfigError.emptyAccesToken {
    print("Remember to set your accessToken with PROCESS_CARDS permission on line 5. For help creating an access_token, read https://docs.clover.com/clover-platform/docs/using-oauth-20")
} catch ConfigError.emptyMerchantId {
    print("Set your merchant ID, which can be found in your merchant dashboard: https://sandbox.dev.clover.com/developers")
} catch ConfigError.emptyOrderId {
    print("For help creating an order, read https://docs.clover.com/clover-platform/docs/working-with-orders")
}
