using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Numerics;
using System.Security.Cryptography;
using System.Text;
using Newtonsoft.Json;

namespace DeveloperPayAPI {
    public class WebPay {
        private const string merchantID = ""; // Enter your merchant ID here.
        private const string orderID = ""; // Enter your order ID here.
        private const string apiToken = ""; // Enter your API Token here.

        private const string targetEnv = "https://sandbox.dev.clover.com/v2/merchant/";

        private const long amount = 100;
        private const long tipAmount = 0;
        private const long taxAmount = 0;
        private const string cardNumber = "4761739001010010";
        private const string expMonth = "12";
        private const string expYear = "2018";
        private const string cvv = "123";

        /**
         *  POST to /v2/merchant/{mId}/pay with the encrypted card data.
         * 
         *  <param name="encryptedCard">The encrypted card data.</param>
         */
        private static void postPayment(string encryptedCard) {
            string posturl = targetEnv + merchantID + "/pay";

            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(posturl);
            request.Method = "POST";
            request.ContentType = "application/json";
            request.Headers.Add("Authorization", "Bearer " + apiToken);

            Dictionary<string, string> postData = new Dictionary<string, string>();
            postData.Add("orderId", orderID);
            postData.Add("currency", "usd");
            postData.Add("amount", amount.ToString());
            postData.Add("tipAmount", tipAmount.ToString());
            postData.Add("taxAmount", taxAmount.ToString());
            postData.Add("expMonth", expMonth);
            postData.Add("expYear", expYear);
            postData.Add("cvv", cvv);
            postData.Add("cardEncrypted", encryptedCard);
            postData.Add("last4", cardNumber.Substring(cardNumber.Length - 4));
            postData.Add("first6", cardNumber.Substring(0, 6));

            string json = JsonConvert.SerializeObject(postData, Formatting.Indented);

            Console.WriteLine(json);

            StreamWriter streamWriter = new StreamWriter(request.GetRequestStream());

            streamWriter.Write(json);
            streamWriter.Flush();
            streamWriter.Close();

            HttpWebResponse response = (HttpWebResponse)request.GetResponse();

            StreamReader readStream = new StreamReader(response.GetResponseStream());
            string stringResult = readStream.ReadToEnd().ToString();

            if ((int)response.StatusCode >= 200 && (int)response.StatusCode <= 299) {
                Console.WriteLine(stringResult);
            }

            else {
                Console.WriteLine("{0} ({1})", (int)response.StatusCode, stringResult);
            }
        }



        public static void Main(string[] args) {
            string url = targetEnv + merchantID + "/pay/key";

            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
            request.Method = "GET";
            request.Headers.Add("Authorization", "Bearer " + apiToken);

            // GET to /v2/merchant/{mId}/pay/key 
            // To get the encryption information needed for the pay endpoint.
            HttpWebResponse response = (HttpWebResponse)request.GetResponse();

            StreamReader readStream = new StreamReader(response.GetResponseStream());
            string stringResult = readStream.ReadToEnd().ToString();

            if ((int)response.StatusCode >= 200 && (int)response.StatusCode <= 299) {
                Dictionary<string, string> jsonResult = 
                    JsonConvert.DeserializeObject<Dictionary<string, string>>(stringResult);
                
                string modulus = jsonResult["modulus"];
                string exponent = jsonResult["exponent"];
                string prefix = jsonResult["prefix"];

                byte[] modulusBytes = BigInteger.Parse(modulus).ToByteArray();
                byte[] exponentBytes = BitConverter.GetBytes(Int64.Parse(exponent));

                // If the byte arrays are little-endian, reverse them to become
                // big-endian to be accepted as RSA parameters.
                if (BitConverter.IsLittleEndian) {
                    Array.Reverse(modulusBytes);
                    Array.Reverse(exponentBytes);
                }

                RSAParameters rsaParams = new RSAParameters {
                    Modulus = modulusBytes,
                    Exponent = exponentBytes
                };

                RSA rsa = RSA.Create();
                rsa.ImportParameters(rsaParams);

                byte[] encryptedCard = rsa.Encrypt(Encoding.UTF8.GetBytes(prefix + cardNumber), 
                                                   RSAEncryptionPadding.OaepSHA1);
                
                string base64EncryptedCard = Convert.ToBase64String(encryptedCard);

                postPayment(base64EncryptedCard);
            }

            else {
                Console.WriteLine("{0} ({1})", (int)response.StatusCode, stringResult);
            }  
        }
    }
}
