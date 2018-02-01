//
//  RNJwtIos.swift
//  RNJwtIos
//
//  Created by Luis Ferreira on 01/02/18.
//  Copyright © 2018 Luis Felipe Zaguini. All rights reserved.
//

import Foundation

@objc(RNJwtIos)
class RNJwtIos: NSObject {
    
    @objc(addEvent:location:date:)
    func addEvent(name: String, location: String, date: NSNumber) -> Void {
        // Date is ready to use!
    }
    
    func constantsToExport() -> [String: Any]! {
        return ["someKey": "someValue"]
    }
    
}
