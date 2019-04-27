
#import "RNPureJwt.h"
#import "JWT.h"

@implementation RNPureJwt

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_REMAP_METHOD(sign,
                 claims:(NSDictionary *)payload
                  secret: (NSString *) secret
                  options: (NSDictionary *) options
                  resolver: (RCTPromiseResolveBlock) resolve
                  rejecter: (RCTPromiseRejectBlock) reject
                 ) {
    JWTClaimsSet *claimsSet = [[JWTClaimsSet alloc] init];
    claimsSet.issuer = @"Facebook";
    claimsSet.subject = @"Token";
    claimsSet.audience = @"http://yourkarma.com";
    claimsSet.expirationDate = [NSDate distantFuture];
    claimsSet.notBeforeDate = [NSDate distantPast];
    claimsSet.issuedAt = [NSDate date];
    claimsSet.identifier = @"thisisunique";
    claimsSet.type = @"test";
    
    id<JWTAlgorithm> algorithm = [JWTAlgorithmFactory algorithmByName:@"HS256"];
    
    NSString *teste = [JWTBuilder encodeClaimsSet:claimsSet].secret(secret).algorithm(algorithm).encode;
    
    resolve(teste);
}

@end
  
