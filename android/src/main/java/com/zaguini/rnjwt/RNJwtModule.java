package com.zaguini.rnjwt;

import com.facebook.react.bridge.ReactApplicationContext;

import com.facebook.react.bridge.ReactContextBaseJavaModule;

import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableMap;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import io.jsonwebtoken.*;

import java.nio.charset.Charset;
import java.util.*;

import android.util.Base64;


public class RNJwtModule extends ReactContextBaseJavaModule {
  public static Gson createDefaultGson() {
    GsonBuilder builder = new GsonBuilder();
    return builder.create();
  }


  private String[] supportedAlgorithms = {"HS256"};

  public RNJwtModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @Override
  public String getName() {
    return "RNJwtAndroid";
  }

  public String getAlg(HashMap<String, Object> options) {
    String alg = "HS256";

    if(options.containsKey("alg") && options.get("alg") != null) {
      String tmpAlg = options.get("alg").toString();

      if(Arrays.asList(this.supportedAlgorithms).contains(tmpAlg)) {
        alg = tmpAlg;
      }
    }

    return alg;
  }

  public String toBase64(String plainString) {
    return Base64.encodeToString(plainString.getBytes(Charset.forName("UTF-8")), Base64.DEFAULT);
  }

  // TODO: decode method
  @ReactMethod
  public void verify(String jwt, String secret, ReadableMap bruteOptions, Promise callback) {
    HashMap<String, Object> options = bruteOptions.toHashMap();

    String alg = this.getAlg(options);

    JwtParser parser = Jwts.parser();

    if(alg.equals("HS256")) {
      parser.setSigningKey(this.toBase64(secret));
    }

    try {
      Object body = parser.parse(jwt).getBody();
      String parsed = this.createDefaultGson().toJson(body);

      callback.resolve(parsed);
    } catch(ExpiredJwtException e) {
      callback.reject("-2", "The JWT is expired.");
    }
  }

  // TODO: verify method
  // TODO: error checking
  // Source: https://github.com/auth0/node-jsonwebtoken

  @ReactMethod
  public void sign(ReadableMap bruteClaims, String secret, ReadableMap bruteOptions, Promise callback) {
    HashMap<String, Object> claims = bruteClaims.toHashMap();
    HashMap<String, Object> options = bruteOptions.toHashMap();

    JwtBuilder constructedToken = Jwts.builder();

    if(!claims.containsKey("exp") || claims.get("exp") == null) {
      callback.reject("-1", "you must pass the expiration Date (exp)");

      return;
    }

    String alg = this.getAlg(options);

    Iterator it = claims.entrySet().iterator();

    while(it.hasNext()) {
      Map.Entry pair = (Map.Entry) it.next();

      Object key = pair.getKey();
      Object value = pair.getValue();

      if(key.equals("alg")) {
        continue;
      }

      if(key.equals("exp")) {
        long duration = (long) bruteClaims.getDouble("exp") * 1000;

        constructedToken.setExpiration(new Date(System.currentTimeMillis() + duration));
      } else {
        constructedToken.claim(key.toString(), value);
      }

      it.remove();
    }

    // TODO: change algorithm based on `alg` variable
    constructedToken = constructedToken.signWith(SignatureAlgorithm.HS256, this.toBase64(secret));

    String token = constructedToken.compact();

    callback.resolve(token);
  }
}
