package com.zaguini.rnjwt;

import com.facebook.react.bridge.ReactApplicationContext;

import com.facebook.react.bridge.ReactContextBaseJavaModule;

import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableMap;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.JwtBuilder;
import io.jsonwebtoken.SignatureAlgorithm;

import java.nio.charset.Charset;
import java.util.HashMap;
import java.util.Arrays;
import java.util.Map;
import java.util.Iterator;

import android.util.Base64;


public class RNJwtModule extends ReactContextBaseJavaModule {
  private String[] supportedAlgorithms = {"HS256", "teste"};

  public RNJwtModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @Override
  public String getName() {
    return "RNJwtAndroid";
  }

  // TODO: decode method
  // TODO: verify method
  // TODO: error checking
  // Source: https://github.com/auth0/node-jsonwebtoken

  @ReactMethod
  public void sign(ReadableMap bruteClaims, String secret, Promise callback) {
    HashMap<String, Object> claims = bruteClaims.toHashMap();
    String alg = "HS256";

    JwtBuilder constructedToken = Jwts.builder();

    if(!claims.containsKey("exp") || claims.get("exp") == null) {
      callback.reject("you must pass the expiration Date (exp)");

      return;
    }

    if(claims.containsKey("alg") && claims.get("alg") != null) {
      String tmpAlg = claims.get("alg").toString();

      if(Arrays.asList(this.supportedAlgorithms).contains(tmpAlg)) {
        alg = tmpAlg;
      }
    }

    Iterator it = claims.entrySet().iterator();

    while(it.hasNext()) {
      Map.Entry pair = (Map.Entry) it.next();

      Object key = pair.getKey();
      Object value = pair.getValue();

      if(new String("alg").equals(key)) {
        continue;
      }

      constructedToken.claim(key.toString(), value);
      it.remove();
    }

    String base64Secret = Base64.encodeToString(secret.getBytes(Charset.forName("UTF-8")), Base64.DEFAULT);

    // TODO: change algorithm based on `alg` variable
    constructedToken = constructedToken.signWith(SignatureAlgorithm.HS256, base64Secret);

    String token = constructedToken.compact();

    callback.resolve(token);
  }
}
