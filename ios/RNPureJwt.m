
#import "RNPureJwt.h"
#import "JWT.h"

@implementation RNPureJwt

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_REMAP_METHOD(sign,
                 claims: (NSDictionary *) claims
                 secret: (NSString *) secret
                 options: (NSDictionary *) options
                 resolver: (RCTPromiseResolveBlock) resolve
                 rejecter: (RCTPromiseRejectBlock) reject
                ) {
    JWTClaimsSet *claimsSet = [[JWTClaimsSet alloc] init];
    
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
    
    for(id key in claims) {
        if([key isEqualToString: @"aud"]) {
            claimsSet.audience = [claims objectForKey:key];
        } else if([key isEqualToString: @"jti"]) {
            claimsSet.identifier = [claims objectForKey:key];
        } else if([key isEqualToString: @"iss"]) {
            claimsSet.issuer = [claims objectForKey:key];
        } else if([key isEqualToString: @"sub"]) {
            claimsSet.subject = [claims objectForKey:key];
        } else if([key isEqualToString: @"typ"]) {
            claimsSet.type = [claims objectForKey:key];
        } else if([key isEqualToString: @"iat"]) {
            NSInteger issuedAt = [[claims objectForKey:key] integerValue] / 1000;
            claimsSet.issuedAt = [NSDate dateWithTimeIntervalSince1970: issuedAt];
        } else if([key isEqualToString: @"nbf"]) {
            NSInteger notBeforeDate = [[claims objectForKey:key] integerValue] / 1000;
            claimsSet.notBeforeDate = [NSDate dateWithTimeIntervalSince1970: notBeforeDate];
        } else if([key isEqualToString: @"exp"]) {
            NSInteger expirationDate = [[claims objectForKey:key] integerValue] / 1000;
            claimsSet.expirationDate = [NSDate dateWithTimeIntervalSince1970: expirationDate];
        } else {
            [payload setObject: [claims objectForKey:key] forKey: key];
        }
    }
    
    JWTEncodingBuilder *builder = [JWTEncodingBuilder encodePayload:payload];
    
    NSString *algorithmName = options[@"alg"] ? options[@"alg"] : @"HS256";
    id holder = [JWTAlgorithmHSFamilyDataHolder new].algorithmName(algorithmName).secret(secret);
    JWTCodingResultType *result = builder.claimsSet(claimsSet).addHolder(holder).result;
    
    if(result.successResult) {
        resolve(result.successResult.encoded);
    } else {
        reject(@"failed", @"Encoding failed", result.errorResult.error);
    }
}

RCT_REMAP_METHOD(decode,
                 token: (NSString *) token
                 secret: (NSString *) secret
                 options: (NSDictionary *) options
                 resolver: (RCTPromiseResolveBlock) resolve
                 rejecter: (RCTPromiseRejectBlock) reject
                 ) {
    NSArray *claimsKeys = @[@"audience", @"identifier", @"issuer", @"subject", @"type", @"issuedAt", @"notBeforeDate", @"expirationDate"];

    JWTClaimsSet *trustedClaims = [[JWTClaimsSet alloc] init];
    BOOL decodeForced = [options[@"skipValidation"] boolValue] == YES;
    
    if(!decodeForced) {
        trustedClaims.expirationDate = [NSDate date];
    }
    
    NSNumber *decodeOptions = @(decodeForced);

    NSString *algorithmName = options[@"alg"] ? options[@"alg"] : @"HS256";
    id holder = [JWTAlgorithmHSFamilyDataHolder new].algorithmName(algorithmName).secret(secret);

    JWTCodingBuilder *verifyBuilder = [JWTDecodingBuilder decodeMessage:token].claimsSet(trustedClaims).options(decodeOptions).addHolder(holder);
    JWTCodingResultType *result = verifyBuilder.result;
    
    if (result.successResult) {
        NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
        [payload addEntriesFromDictionary: result.successResult.payload];

        NSDictionary *claims = [result.successResult.claimsSet dictionaryWithValuesForKeys: claimsKeys];

        for(id key in claims) {
            if([key isEqualToString: @"audience"] && claims[key] != [NSNull null]) {
                payload[@"aud"] = claims[key];
            }

            if([key isEqualToString: @"identifier"] && claims[key] != [NSNull null]) {
                payload[@"jti"] = claims[key];
            }

            if([key isEqualToString: @"issuer"] && claims[key] != [NSNull null]) {
                payload[@"iss"] = claims[key];
            }

            if([key isEqualToString: @"subject"] && claims[key] != [NSNull null]) {
                payload[@"sub"] = claims[key];
            }

            if([key isEqualToString: @"expirationDate"] && [[NSDate dateWithTimeIntervalSince1970: 0] compare: claims[key]] != NSOrderedSame) {
                double time = [[claims valueForKey:@"expirationDate"] timeIntervalSince1970];
                [payload setValue:[NSNumber numberWithDouble: time] forKey:@"exp"];
            }

            if([key isEqualToString: @"issuedAt"] && [[NSDate dateWithTimeIntervalSince1970: 0] compare: claims[key]] != NSOrderedSame) {
                double time = [[claims valueForKey:@"issuedAt"] timeIntervalSince1970];
                [payload setValue:[NSNumber numberWithDouble: time] forKey:@"iat"];
            }

            if([key isEqualToString: @"notBeforeDate"] && [[NSDate dateWithTimeIntervalSince1970: 0] compare: claims[key]] != NSOrderedSame) {
                double time = [[claims valueForKey:@"notBeforeDate"] timeIntervalSince1970];
                [payload setValue:[NSNumber numberWithDouble: time] forKey:@"nbf"];
            }
        }


        resolve(@{
                  @"headers": result.successResult.headers,
                  @"payload": payload,
                  });
    }
    else {
        reject(@"failed", @"Decoding failed", result.errorResult.error);
    }
}

@end
  
