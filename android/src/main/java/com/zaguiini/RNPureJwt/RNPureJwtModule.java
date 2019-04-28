package com.zaguiini.RNPureJwt;

import android.util.Base64;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;

import java.nio.charset.Charset;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;

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

    @ReactMethod
    public void sign(ReadableMap claims, String secret, ReadableMap options, Promise callback) {
        String jws = Jwts.builder().setSubject("Joe")
                .signWith(SignatureAlgorithm.HS256, this.toBase64(secret))
                .compact();

        callback.resolve(jws);
    }
}
