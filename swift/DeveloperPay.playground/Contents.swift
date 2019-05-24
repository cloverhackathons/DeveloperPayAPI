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

enum ConfigError: Error {
    case emptyAccesToken
    case emptyMerchantId
    case emptyOrderId
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
    
    return (exponentEncoded!, modulusEncoded!, prefix, modulusArray!.count)
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
            print(exponent, modulus, prefix, modulusCount)
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
