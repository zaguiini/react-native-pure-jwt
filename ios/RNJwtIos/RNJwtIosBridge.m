//
//  RNJwtIosBridge.m
//  RNJwtIos
//
//  Created by Luis Ferreira on 01/02/18.
//  Copyright © 2018 Luis Felipe Zaguini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(RNJwtIos, NSObject)

RCT_EXTERN_METHOD(addEvent:(NSString *)name location:(NSString *)location date:(nonnull NSNumber *)date)

@end
