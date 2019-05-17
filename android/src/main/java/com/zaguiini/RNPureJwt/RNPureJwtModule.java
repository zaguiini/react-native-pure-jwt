package com.zaguiini.RNPureJwt;

import android.util.Base64;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.nio.charset.Charset;
import java.util.Date;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;

import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwt;
import io.jsonwebtoken.JwtBuilder;
import io.jsonwebtoken.JwtParser;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.SignatureException;
import io.jsonwebtoken.impl.DefaultClaims;

public class RNPureJwtModule extends ReactContextBaseJavaModule {

    public RNPureJwtModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
    return "RNPureJwt";
  }

    private String toBase64(String plainString) {
        return Base64.encodeToString(plainString.getBytes(Charset.forName("UTF-8")), Base64.DEFAULT);
    }

    private String base64toString(String plainString) {
        return new String(Base64.decode(plainString, Base64.DEFAULT));
    }

    private void getResponse(String token, Promise callback) {
        ObjectMapper mapper = new ObjectMapper();
        WritableMap response = Arguments.createMap();

        String[] parts = token.split(Pattern.quote("."));

        try {
            Map<String, Object> headers = mapper.readValue(
                    this.base64toString(parts[0]),
                    new TypeReference<Map<String, Object>>() {}
            );

            response.putMap("headers", Arguments.makeNativeMap(headers));
        } catch(IOException e) {
            callback.reject("7", "Invalid header");
        }

        try {
            Map<String, Object> payload = mapper.readValue(
                    this.base64toString(parts[1]),
                    new TypeReference<Map<String, Object>>() {}
            );

            response.putMap("payload", Arguments.makeNativeMap(payload));
        } catch(IOException e) {
            callback.reject("8", "Invalid payload");
        }


        callback.resolve(response);
    }

    private void getResponse(Jwt parsed, Promise callback) {
        ObjectMapper mapper = new ObjectMapper();

        Map<String, Object> headersMap = mapper.convertValue(parsed.getHeader(), DefaultClaims.class);
        Map<String, Object> payload = mapper.convertValue(parsed.getBody(), DefaultClaims.class);

        WritableMap response = Arguments.createMap();

        response.putMap("headers", Arguments.makeNativeMap(headersMap));
        response.putMap("payload", Arguments.makeNativeMap(payload));

        callback.resolve(response);
    }

    @ReactMethod
    public void decode(String token, String secret, ReadableMap options, Promise callback) {
        JwtParser parser = Jwts.parser().setSigningKey(this.toBase64(secret));

        Boolean skipValidation = false;

        Set<Map.Entry<String, Object>> entries = options.toHashMap().entrySet();

        for (Object entry: entries) {
            Map.Entry item = (Map.Entry) entry;

            String key = (String) item.getKey();
            Object value = item.getValue();

            switch(key) {
                case "skipValidation":
                    skipValidation = (boolean) value;
                    break;
            }
        }

        Jwt parsed;

        try {
            parsed = parser.parse(token);
        } catch(MalformedJwtException e) {
            if(skipValidation) {
                this.getResponse(token, callback);
                return;
            }

            callback.reject("2", "The JWT is invalid.");

            return;
        } catch(ExpiredJwtException e) {
            if(skipValidation) {
                this.getResponse(token, callback);
                return;
            }

            callback.reject("3", "The JWT is expired.");
            return;
        } catch(SignatureException e) {
            if(skipValidation) {
                this.getResponse(token, callback);
                return;
            }

            callback.reject("6", "Invalid signature.");

            return;
        } catch(Exception e) {
            callback.reject("0", e);

            return;
        }

        this.getResponse(parsed, callback);
    }

    @ReactMethod
    public void sign(ReadableMap claims, String secret, ReadableMap options, Promise callback) {
        String algorithm = options.hasKey("alg") ? options.getString("alg") : "HS256";
        JwtBuilder constructedToken = Jwts.builder()
                .signWith(SignatureAlgorithm.forName(algorithm), this.toBase64(secret))
                .setHeaderParam("alg", algorithm)
                .setHeaderParam("typ", "JWT");

        Set<Map.Entry<String, Object>> entries = claims.toHashMap().entrySet();

        for (Object entry: entries) {
            Map.Entry item = (Map.Entry) entry;

            String key = (String) item.getKey();
            Object value = item.getValue();

            Double valueAsDouble;

            switch (key) {
                case "alg":
                    break;

                case "exp":
                    valueAsDouble = (double) value;
                    constructedToken.setExpiration(new Date(valueAsDouble.longValue()));
                    break;

                case "iat":
                    valueAsDouble = (double) value;
                    constructedToken.setIssuedAt(new Date(valueAsDouble.longValue()));
                    break;

                case "nbf":
                    valueAsDouble = (double) value;
                    constructedToken.setNotBefore(new Date(valueAsDouble.longValue()));
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
                    constructedToken.claim(key, value);
            }
        }

        callback.resolve(constructedToken.compact());
    }
}
