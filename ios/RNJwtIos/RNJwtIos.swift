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

    @objc(sign:payload:secret:options:resolve:reject:)
    func sign(
        payload: NSDictionary,
        secret: String,
        options: NSDictionary,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) -> Void {
        resolve(true)
    }
}
