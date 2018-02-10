//
//  RNJwtIos.swift
//  agoravai
//
//  Created by Luis Ferreira on 02/02/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation
import JWT

class InvalidAlgorithmError: Error {
    
}

class InvalidJWTError: Error {
    
}

@objc(RNJwtIos)
class RNJwtIos: NSObject {
    let bypassedClaims: [String] = ["iat", "aud", "nbf", "iss", "exp"]
    
    func getAlg(alg: String, secret: String) -> Optional<Algorithm> {
        switch(alg.uppercased()) {
        case "HS256":
            return Algorithm.hs256(secret.data(using: .utf8)!)
            
        default:
            return nil
        }
    }
    
    func getClaims(bruteClaims: NSDictionary) -> NSDictionary {
        var claims = bruteClaims
        
        for(claim) in bypassedClaims {
            if claim == "aud" {
                continue
            }
            
            if let value = claims[claim] {
                claims[claim] = Int((value as! Double) * 1000)
            }
        }
        
        return claims
    }
    
    @objc(decode:options:resolver:rejecter:)
    func decode(
        token: String,
        options: NSDictionary,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
        ) {
        do {
            let decoded: (headers: JOSEHeader, claims: ClaimSet) = try JWT.decodeWithHeaders(token, algorithms: [Algorithm.none], verify: false)
            
            let complete = options["complete"] as! Bool
            let payload = getClaims(decoded.claims.claims)
            
            if complete {
                var headers = [
                    "typ": decoded.headers.type,
                    "alg": decoded.headers.algorithm,
                    ]
                
                if decoded.headers.contentType != nil {
                    headers["cty"] = decoded.headers.contentType
                }
                
                if decoded.headers.keyID != nil {
                    headers["kid"] = decoded.headers.keyID
                }
                
                resolve([
                    "headers": headers as Any,
                    "payload": payload
                ])
            } else {
                resolve(payload)
            }
        } catch {
            reject("InvalidJWTError", "Error: invalid JWT", InvalidJWTError())
        }
    }
    
    @objc(verify:secret:options:resolver:rejecter:)
    func verify(
        token: String,
        secret: String,
        options: NSDictionary,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
        ) {
        if let alg = getAlg(alg: options["alg"] as! String, secret: secret) {
            do {
                let claims: ClaimSet = try JWT.decode(token, algorithm: alg)
                
                resolve(getClaims(claims.claims))
            } catch {
                reject("DecodeError", "Error decoding JWT", error)
            }
        } else {
            reject("InvalidAlgorithmError", "Invalid algorithm.", InvalidAlgorithmError())
        }
    }
    
    @objc(sign:secret:options:resolver:rejecter:)
    func sign(
        payload: NSDictionary,
        secret: String,
        options: NSDictionary,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
        ) -> Void {
        if let alg = getAlg(alg: options["alg"] as! String, secret: secret) {
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
        } else {
            reject("InvalidAlgorithmError", "Invalid algorithm.", InvalidAlgorithmError())
        }
    }
}

