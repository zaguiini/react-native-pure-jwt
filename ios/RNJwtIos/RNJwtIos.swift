//
//  RNJwtIos.swift
//  RNJwtIos
//
//  Created by Luis Ferreira on 01/02/18.
//  Copyright © 2018 Luis Felipe Zaguini. All rights reserved.
//

import Foundation
import JWT

@objc(RNJwtIos)
class RNJwtIos: NSObject {
//
//    (sign:payload:secret:options:resolve:reject:)
    @objc func sign(
        payload: NSDictionary,
        secret: String,
        options: NSDictionary,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) -> Void {
        print(JWT)
        print("SOLTA SA PORRA")
        resolve(true)
    }
    
    @obj(top:)
    func top() -> Void {
        print("ta porra")
    }
}
