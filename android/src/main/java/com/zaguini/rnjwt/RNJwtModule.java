package com.zaguini.rnjwt;

import android.text.TextUtils;
import com.facebook.react.bridge.*;
import com.fasterxml.jackson.core.type.TypeReference;
import io.jsonwebtoken.*;

import java.io.IOException;
import java.nio.charset.Charset;
import java.util.*;
import java.util.regex.Pattern;

import com.fasterxml.jackson.databind.ObjectMapper;

import android.util.Base64;
import io.jsonwebtoken.impl.DefaultClaims;

public class RNJwtModule extends ReactContextBaseJavaModule {
  private String[] supportedAlgorithms = {"HS256"};

  public RNJwtModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @Override
  public String getName() {
    return "RNJwtAndroid";
  }

  private String getAlg(HashMap<String, Object> options) {
    Boolean found = false;
    String alg = "HS256";

    if(options.containsKey("alg") && options.get("alg") != null) {
      String tmpAlg = options.get("alg").toString().toUpperCase();

      if(Arrays.asList(this.supportedAlgorithms).contains(tmpAlg)) {
        alg = tmpAlg;
        found = true;
      }
    }

    if(!found) {
      throw new java.lang.Error("invalid algorithm");
    }

    return alg;
  }

  private String toBase64(String plainString) {
    return Base64.encodeToString(plainString.getBytes(Charset.forName("UTF-8")), Base64.DEFAULT);
  }

  private String base64toString(String plainString) {
    return new String(Base64.decode(plainString, Base64.DEFAULT));
  }

  @ReactMethod
  public void decode(String jwt, Promise callback) {
    ObjectMapper mapper = new ObjectMapper();
    WritableMap response = Arguments.createMap();

    String[] parts = jwt.split(Pattern.quote("."));

    try {
      Map<String, Object> payloadMap = mapper.readValue(
              this.base64toString(parts[1]),
              new TypeReference<Map<String, Object>>() {}
      );

      WritableMap payload = Arguments.makeNativeMap(payloadMap);
      payload.putDouble("exp", payload.getDouble("exp") * 1000);

      response.merge(payload);
    } catch(IOException e) {
      callback.reject("4", "invalid payload");

      return;
    }

    callback.resolve(response);
  }

  @ReactMethod
  public void decode(String jwt, ReadableMap bruteOptions, Promise callback) {
    ObjectMapper mapper = new ObjectMapper();
    WritableMap response = Arguments.createMap();

    String[] parts = jwt.split(Pattern.quote("."));
    List<String> errors = new ArrayList<>();

    Boolean hasHeader = false;

    if(bruteOptions != null && bruteOptions.hasKey("complete") && bruteOptions.getBoolean("complete")) {
      hasHeader = true;

      try {
        Map<String, Object> headers = mapper.readValue(
          this.base64toString(parts[0]),
          new TypeReference<Map<String, Object>>() {}
        );

        response.putMap("headers", Arguments.makeNativeMap(headers));
      } catch(IOException e) {
        errors.add("invalid header");
      }
    }

    try {
      Map<String, Object> payloadMap = mapper.readValue(
              this.base64toString(parts[1]),
              new TypeReference<Map<String, Object>>() {}
      );

      WritableMap payload = Arguments.makeNativeMap(payloadMap);
      payload.putDouble("exp", payload.getDouble("exp") * 1000);

      if(hasHeader) {
        response.putMap("payload", payload);
      } else {
        response.merge(payload);
      }
    } catch(IOException e) {
      errors.add("invalid payload");
    }

    if(!errors.isEmpty()) {
      callback.reject("4", TextUtils.join(", ", errors));
    } else {
      callback.resolve(response);
    }
  }

  @ReactMethod
  public void verify(String jwt, String secret, ReadableMap bruteOptions, Promise callback) {
    HashMap<String, Object> options = bruteOptions.toHashMap();
    String alg;

    try {
      alg = this.getAlg(options);
    } catch(Exception e) {
      callback.reject("5", "Invalid algorithm");

      return;
    }

    JwtParser parser = Jwts.parser();

    if(alg.equals("HS256")) {
      parser.setSigningKey(this.toBase64(secret));
    }

    Jwt parsed;

    try {
      parsed = parser.parse(jwt);
    } catch(MalformedJwtException e) {
      callback.reject("2", "The JWT is invalid.");

      return;
    } catch(ExpiredJwtException e) {
      callback.reject("3", "The JWT is expired.");

      return;
    } catch(SignatureException e) {
      callback.reject("6", "Invalid signature.");

      return;
    } catch(Exception e) {
      callback.reject("0", e);

      return;
    }

    ObjectMapper mapper = new ObjectMapper();

    Map<String, Object> headersMap = mapper.convertValue(parsed.getHeader(), DefaultClaims.class);
    Map<String, Object> body = mapper.convertValue(parsed.getBody(), DefaultClaims.class);

    WritableMap headers = Arguments.makeNativeMap(headersMap);
    WritableMap response = Arguments.makeNativeMap(body);

    response.putDouble("exp", response.getDouble("exp") * 1000);
    response.merge(headers);

    callback.resolve(response);
  }

  @ReactMethod
  public void sign(ReadableMap bruteClaims, String secret, ReadableMap bruteOptions, Promise callback) {
    HashMap<String, Object> claims = bruteClaims.toHashMap();
    HashMap<String, Object> options = bruteOptions.toHashMap();

    JwtBuilder constructedToken = Jwts.builder();

    if(!claims.containsKey("exp") || claims.get("exp") == null) {
      callback.reject("1", "you must pass the expiration Date (exp)");

      return;
    }

    String alg;

    try {
        alg = this.getAlg(options);
    } catch(Error e) {
        callback.reject("5", "Invalid algorithm");

        return;
    }

    Iterator it = claims.entrySet().iterator();

    while(it.hasNext()) {
      Map.Entry pair = (Map.Entry) it.next();

      Object key = pair.getKey();
      Object value = pair.getValue();

      switch(key.toString()) {
        case "alg":
        case "typ":
          break;

        case "exp":
          constructedToken.setExpiration(new Date((long) bruteClaims.getDouble("exp")));
          break;

        case "iat":
          constructedToken.setIssuedAt(new Date((long) bruteClaims.getDouble("iat")));
          break;

        case "nbf":
          constructedToken.setNotBefore(new Date((long) bruteClaims.getDouble("nbf")));
          break;

        case "aud":
          constructedToken.setAudience(value.toString());
          break;

        case "iss":
          constructedToken.setIssuer(value.toString());
          break;

        case "sub":
          constructedToken.setSubject(value.toString());
          break;

        case "jti":
          constructedToken.setId(value.toString());
          break;

        default:
          constructedToken.claim(key.toString(), value);
      }

      it.remove();
    }

    constructedToken.setHeaderParam("typ", "JWT");
    constructedToken = constructedToken.signWith(SignatureAlgorithm.forName(alg), this.toBase64(secret));

    String token = constructedToken.compact();

    callback.resolve(token);
  }
}
