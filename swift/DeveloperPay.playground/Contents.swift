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

// Make sure configuration variables are set before proceeding
func main() throws {
    if accessToken.isEmpty {
        throw ConfigError.emptyAccesToken
    } else if merchantId.isEmpty {
        throw ConfigError.emptyMerchantId
    } else if orderId.isEmpty {
        throw ConfigError.emptyOrderId
    } else {
        // Do the things
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
