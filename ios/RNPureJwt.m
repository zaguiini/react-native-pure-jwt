
#import "RNPureJwt.h"
#import "JWT.h"

@implementation RNPureJwt

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_REMAP_METHOD(sign,
                 claims:(NSDictionary *)claims
                 secret: (NSString *) secret
                 options: (NSDictionary *) options
                 resolver: (RCTPromiseResolveBlock) resolve
                 rejecter: (RCTPromiseRejectBlock) reject
                ) {
    JWTClaimsSet *claimsSet = [[JWTClaimsSet alloc] init];
    
    for(id key in claims) {
//        claimsSet.expirationDate; EXP
//        claimsSet.issuedAt; IAT
//        claimsSet.notBeforeDate; NBF
        
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
        } else if([key isEqualToString: @"iat"]) { // DOING ISSUED AT
            claimsSet.issuedAt = [NSDate dateWithTimeIntervalSince1970: 1000];
        } else {
            [claimsSet setValue: [claims objectForKey:key] forKey: key];
        }
    }

    // encode it
    NSString *algorithmName = @"HS256";
    
    id holder = [JWTAlgorithmHSFamilyDataHolder new].algorithmName(algorithmName).secret(secret);
    JWTCodingResultType *result = [JWTEncodingBuilder encodeClaimsSet:claimsSet].addHolder(holder).result;

    NSString *encodedToken = result.successResult.encoded;
    
    resolve(encodedToken);
}

@end
  
