//
//  RNJwtIosBridge.m
//  RNJwtIos
//
//  Created by Luis Ferreira Zaguini on 02/02/18.
//  Copyright © 2018 Luis Felipe Zaguini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(RNJwtIos, NSObject)

RCT_EXTERN_METHOD(
                  sign:
                  (NSDictionary *) payload
                  secret: (NSString *) secret
                  options: (NSDictionary *) options
                  resolver: (RCTPromiseResolveBlock) resolve
                  rejecter: (RCTPromiseRejectBlock) reject
                  )

RCT_EXTERN_METHOD(
                  verify:
                  (NSString *) token
                  secret: (NSString *) secret
                  options: (NSDictionary *) options
                  resolver: (RCTPromiseResolveBlock) resolve
                  rejecter: (RCTPromiseRejectBlock) reject
                  )

RCT_EXTERN_METHOD(
                  decode:
                  (NSString *) token
                  options: (NSDictionary *) options
                  resolver: (RCTPromiseResolveBlock) resolve
                  rejecter: (RCTPromiseRejectBlock) reject
                  )

@end

