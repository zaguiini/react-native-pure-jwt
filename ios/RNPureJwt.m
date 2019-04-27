
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
    // fill it
    claimsSet.issuer = @"Facebook";
    claimsSet.subject = @"Token";
    claimsSet.audience = @"https://jwt.io";
    
    // encode it
    NSString *algorithmName = @"HS384";
    NSDictionary *headers = @{@"custom":@"value"};
    
    id holder = [JWTAlgorithmHSFamilyDataHolder new].algorithmName(algorithmName).secret(secret);
    
    JWTCodingResultType *result = [JWTEncodingBuilder encodeClaimsSet:claimsSet].headers(headers).addHolder(holder).result;

    NSString *encodedToken = result.successResult.encoded;
    
    resolve(encodedToken);
}

@end
  
