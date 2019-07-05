package com.company;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpRequestBase;
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.bouncycastle.jce.provider.BouncyCastleProvider;

import javax.crypto.Cipher;
import javax.xml.bind.DatatypeConverter;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.math.BigInteger;
import java.net.URI;
import java.security.KeyFactory;
import java.security.PublicKey;
import java.security.SecureRandom;
import java.security.Security;
import java.security.spec.RSAPublicKeySpec;

public class Main {
  static final Gson GSON = new Gson();
  static final JsonParser JSON_PARSER = new JsonParser();
  static final CloseableHttpClient client = HttpClientBuilder.create().build();

  // Clover Credentials
  static final String BASE_URL = "https://apisandbox.dev.clover.com"; // "https://api.clover.com";
  static final String MERCHANT_ID = "TEST MERCHANT ID";
  static final String ACCESS_TOKEN = "TEST ACCESS TOKEN";

  // Test Credit Card Info
  static final String CC_NUMBER = "TEST CREDIT CARD NUMBER";
  static final String CVV_NUMBER = "123";
  static final int EXP_MONTH = 0;
  static final int EXP_YEAR = 2000;

  public static void main(String[] args) {
    try {
      testWebPay();
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  private static void testWebPay() throws Exception {
    System.out.println("Creating Order");
    JsonObject order = sendPost("/v3/merchants/" + MERCHANT_ID + "/orders", new JsonObject());
    final String orderId = order.get("id").getAsString();

    System.out.println("Get any Item Id");
    final URI uri = new URIBuilder("/v3/merchants/" + MERCHANT_ID + "/items").addParameter("filter", "price>0").addParameter("limit", "1").build();
    final JsonObject elements = sendGet(uri.toASCIIString());
    final JsonObject item = elements.getAsJsonArray("elements").get(0).getAsJsonObject();
    final String itemId = item.get("id").getAsString();
    final long itemPrice = item.get("price").getAsLong();

    System.out.println("Add Item");
    item.addProperty("id", itemId);
    final JsonObject lineItems = new JsonObject();
    lineItems.add("item", item);
    sendPost("/v3/merchants/" + MERCHANT_ID + "/orders/" + orderId + "/line_items", lineItems);

    System.out.println("Update Order Total");
    final JsonObject orderUpdate = new JsonObject();
    orderUpdate.addProperty("total", itemPrice);
    order = sendPost("/v3/merchants/" + MERCHANT_ID + "/orders/" + orderId, orderUpdate);

    System.out.println("Get Payment Key");
    final JsonObject keys = sendGet("/v2/merchant/" + MERCHANT_ID + "/pay/key");
    final String modulus = keys.get("modulus").getAsString();
    final String exponent = keys.get("exponent").getAsString();
    final String prefix = keys.get("prefix").getAsString();

    final PublicKey publicKey = getPublicKey(new BigInteger(modulus), new BigInteger(exponent));
    final String ccEncrypted = encryptPAN(prefix, CC_NUMBER, publicKey);

    final JsonObject payment = new JsonObject();
    payment.addProperty("orderId", orderId);
    payment.addProperty("currency", "usd");
    payment.addProperty("expMonth", EXP_MONTH);
    payment.addProperty("cvv", CVV_NUMBER);
    payment.addProperty("expYear", EXP_YEAR);
    payment.addProperty("cardEncrypted", ccEncrypted);

    final double total = order.get("total").getAsDouble();
    payment.addProperty("amount", total);

    final int length = CC_NUMBER.length();
    payment.addProperty("last4", CC_NUMBER.substring(length - 4, length));
    payment.addProperty("first6", CC_NUMBER.substring(0, 6));

    System.out.println("Post Payment");
    sendPost("/v2/merchant/" + MERCHANT_ID + "/pay", payment);
  }

  public static PublicKey getPublicKey(final BigInteger modulus, final BigInteger exponent) throws Exception {
    final KeyFactory factory = KeyFactory.getInstance("RSA");
    return factory.generatePublic(new RSAPublicKeySpec(modulus, exponent));
  }

  public static String encryptPAN(final String prefix, final String pan, PublicKey publicKey) throws Exception {
    byte[] input = String.format("%s%s", prefix, pan).getBytes();
    Security.addProvider(new BouncyCastleProvider());
    Cipher cipher = Cipher.getInstance("RSA/None/OAEPWithSHA1AndMGF1Padding", "BC");
    cipher.init(Cipher.ENCRYPT_MODE, publicKey, new SecureRandom());
    byte[] cipherText = cipher.doFinal(input);
    return DatatypeConverter.printBase64Binary(cipherText);
  }

  private static JsonObject sendGet(String endpoint) throws Exception {
    HttpGet request = new HttpGet(BASE_URL + endpoint);
    request.addHeader("Authorization", "Bearer " + ACCESS_TOKEN);
    return executeRequest(request);
  }

  private static JsonObject sendPost(String endpoint, JsonObject object) throws Exception {
    final String jsonString = GSON.toJson(object);
    System.out.println("Posting: " + jsonString);

    HttpPost request = new HttpPost(BASE_URL + endpoint);
    request.setEntity(new StringEntity(jsonString, "UTF-8"));
    return executeRequest(request);
  }

  private static JsonObject executeRequest(HttpRequestBase request) throws Exception {
    request.addHeader("Authorization", "Bearer " + ACCESS_TOKEN);
    request.addHeader("Content-Type", "application/json");

    System.out.println(request.toString());
    CloseableHttpResponse response = client.execute(request);

    final int statusCode = response.getStatusLine().getStatusCode();
    System.out.println("Response Code : " + statusCode);
    if (statusCode != 200) {
      throw new Exception("EXITING EARLY - INVALID RESPONSE CODE");
    }

    BufferedReader rd = new BufferedReader(new InputStreamReader(response.getEntity().getContent()));

    String line;
    StringBuilder result = new StringBuilder();
    while ((line = rd.readLine()) != null) {
      result.append(line);
    }
    final String json = result.toString();
    System.out.println(json);
    System.out.println("\n");

    response.close();
    return JSON_PARSER.parse(json).getAsJsonObject();
  }
}
