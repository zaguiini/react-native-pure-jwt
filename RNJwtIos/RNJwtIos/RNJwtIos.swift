//
//  RNJwtIos.swift
//  agoravai
//
//  Created by Luis Ferreira on 02/02/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation
import JWT

class InvalidPayloadError: Error {
  
}

class InvalidOptionsError: Error {
  
}

class InvalidAlgorithmError: Error {
  
}

@objc(RNJwtIos)
class RNJwtIos: NSObject {
  let bypassedClaims: [String] = ["iat", "aud", "nbf", "iss", "exp"]
  
  func validate(type: String, value: NSDictionary) -> Bool {
    if type == "payload" {
      if value["exp"] == nil {
        return false
      }
      
      return true
    } else if type == "options" {
      if value["alg"] == nil {
        return false
      }
      
      return true
    }
    
    return false
  }
  
  @objc(sign:secret:options:resolver:rejecter:)
  func sign(
    payload: NSDictionary,
    secret: String,
    options: NSDictionary,
    resolver resolve: RCTPromiseResolveBlock,
    rejecter reject: RCTPromiseRejectBlock
  ) -> Void {
    if !validate(type: "payload", value: payload) {
      reject("H1", "H2", InvalidPayloadError())
      return
    }
    
    if !validate(type: "options", value: options) {
      reject("Invalid options", "Invalid options", InvalidOptionsError())
      return
    }
    
    var alg: Algorithm
    
    switch((options["alg"] as! String).uppercased()) {
      case "HS256":
        alg = .hs256(secret.data(using: .utf8)!)
        break
      
      default:
        reject("Invalid algorithm", "Invalid algorithm. Valid: HS256", InvalidAlgorithmError())
        return
    }
    
    let encoded = encode(alg) { claims in
      claims.issuedAt = payload["iat"] != nil ? Date(timeIntervalSince1970: (payload["iat"] as! Double) / 1000) : Date()
      
      claims.expiration = Date(timeIntervalSince1970: (payload["exp"] as! Double) / 1000)
      
      if let audience = payload["aud"] as? String {
        claims.audience = audience
      }
      
      if let issuer = payload["iss"] as? String {
        claims.issuer = issuer
      }
      
      if let notBefore = payload["nbf"] {
        claims.notBefore = Date(timeIntervalSince1970: (notBefore as! Double) / 1000)
      }
      
      for(key, value) in payload {
        if(!bypassedClaims.contains(key as! String)) {
          claims[key as! String] = value
        }
      }
    }
    
    resolve(encoded)
  }
}
