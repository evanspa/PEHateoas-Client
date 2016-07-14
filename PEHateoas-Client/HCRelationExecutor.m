//
//  HCRelationExecutor.m
//
// Copyright (c) 2014-2015 PEHateoas-Client
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <PEObjc-Commons/PEUtils.h>
#import "HCRelationExecutor.h"
#import "HCAFURLRequestSerializer.h"
#import "HCAFURLResponseSerializer.h"
#import "NSURLRequest+HCAdditions.h"
#import "HCLogging.h"
#import "HCUtils.h"
#import "HCDeserializedPair.h"
#import "HCResource.h"
#import "HCAuthentication.h"
#import "HCMediaType.h"
#import "HCResourceSerializer.h"

NSString * const HTTP_DATE_FORMAT = @"EEE',' dd MMM yyyy HH':'mm':'ss z";

typedef void (^AFSuccessBlk)(AFHTTPRequestOperation *, id);
typedef void (^AFFailureBlk)(AFHTTPRequestOperation *, NSError *);

@implementation HCRelationExecutor {
  AFSecurityPolicy *_afsecurityPolicy;
}

#pragma mark - Initializers

- (id)initWithDefaultAcceptCharset:(HCCharset *)acceptCharset
             defaultAcceptLanguage:(NSString *)acceptLanguage
         defaultContentTypeCharset:(HCCharset *)contentTypeCharset
          allowInvalidCertificates:(BOOL)allowInvalidCertificates {
  self = [super init];
  if (self) {
    _acceptCharset = acceptCharset;
    _acceptLanguage = acceptLanguage;
    _contentTypeCharset = contentTypeCharset;
    _allowInvalidCertificates = allowInvalidCertificates;
    _afsecurityPolicy = [[AFSecurityPolicy alloc] init];
    [_afsecurityPolicy setAllowInvalidCertificates:allowInvalidCertificates];
  }
  return self;
}

#pragma mark - Helpers

- (NSString *)urlForResource:(HCResource *)resource
                    forOpMgr:(AFHTTPRequestOperationManager *)mgr {
  return [[NSURL URLWithString:[[resource uri] absoluteString]
                 relativeToURL:[mgr baseURL]] absoluteString];
}

- (NSURLRequest *)requestWithOpMgr:(AFHTTPRequestOperationManager *)mgr
                        httpMethod:(NSString *)httpMethod
                          resource:(HCResource *)resource
                        parameters:(NSDictionary *)parameters {
  return [self requestWithOpMgr:mgr
                     httpMethod:httpMethod
                      URLString:[self urlForResource:resource forOpMgr:mgr]
                     parameters:parameters];
}

- (NSURLRequest *)requestWithOpMgr:(AFHTTPRequestOperationManager *)mgr
                        httpMethod:(NSString *)httpMethod
                         URLString:(NSString *)URLString
                        parameters:(NSDictionary *)parameters {
  return [[mgr requestSerializer] requestWithMethod:httpMethod
                                          URLString:URLString
                                         parameters:parameters
                                              error:nil];
}

- (AFHTTPRequestOperationManager *)reqOpMgrWithRequestSerializer:(id<HCResourceSerializer>)reqSerializer
                                              responseSerializer:(id<HCResourceSerializer>)respSerializer
                                                   authorization:(HCAuthorization *)authorization
                                                         timeout:(NSInteger)timeout
                                                     cachePolicy:(NSURLRequestCachePolicy)cachePolicy
                                                    otherHeaders:(NSDictionary *)otherHeaders{
  AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
  HCAFURLRequestSerializer *hcReqSerializer;
  if (reqSerializer) {
    hcReqSerializer =
      [[HCAFURLRequestSerializer alloc] initWithAccept:[respSerializer mediaType]
                                         acceptCharset:_acceptCharset
                                        acceptLanguage:_acceptLanguage
                                         authorization:authorization
                                          hcserializer:reqSerializer
                                               timeout:timeout
                                           cachePolicy:cachePolicy
                                          otherHeaders:otherHeaders];
  } else {
    hcReqSerializer =
      [[HCAFURLRequestSerializer alloc] initWithAccept:[respSerializer mediaType]
                                         acceptCharset:_acceptCharset
                                        acceptLanguage:_acceptLanguage
                                         authorization:authorization
                                               timeout:timeout
                                           cachePolicy:cachePolicy
                                          otherHeaders:otherHeaders];
  }
  [mgr setRequestSerializer:hcReqSerializer];
  if (respSerializer) {
    HCAFURLResponseSerializer *hcRespSerializer =
      [[HCAFURLResponseSerializer alloc] initWithHCSerializer:respSerializer];
    [mgr setResponseSerializer:hcRespSerializer];
  }
  return mgr;
}

- (AFHTTPRequestOperationManager *)reqOpMgrWithResponseSerializer:(id<HCResourceSerializer>)respSerializer
                                                    authorization:(HCAuthorization *)authorization
                                                          timeout:(NSInteger)timeout
                                                      cachePolicy:(NSURLRequestCachePolicy)cachePolicy
                                                     otherHeaders:(NSDictionary *)otherHeaders {
  return [self reqOpMgrWithRequestSerializer:nil
                          responseSerializer:respSerializer
                               authorization:authorization
                                     timeout:timeout
                                 cachePolicy:cachePolicy
                                otherHeaders:otherHeaders];
}

- (AFHTTPRequestOperationManager *)reqOpMgrWithAuthorization:(HCAuthorization *)authorization
                                                     timeout:(NSInteger)timeout
                                                 cachePolicy:(NSURLRequestCachePolicy)cachePolicy
                                                otherHeaders:(NSDictionary *)otherHeaders {
  return [self reqOpMgrWithRequestSerializer:nil
                          responseSerializer:nil
                               authorization:authorization
                                     timeout:timeout
                                 cachePolicy:cachePolicy
                                otherHeaders:otherHeaders];
}

+ (NSDateFormatter *)dateFormatterWithPattern:(NSString *)pattern {
  NSDateFormatter *dateFormatter;
  dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
  dateFormatter.dateFormat = pattern;
  return dateFormatter;
}

- (NSDate *)dateFromRetryAfterHeaderVal:(NSString *)retryAfterHdrVal {
  NSDate *retryAfter = nil;
  NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
  NSNumber *retryAfterNum = [numFormatter numberFromString:retryAfterHdrVal];
  if (retryAfterNum) {
    NSDate *now = [NSDate date];
    retryAfter = [now dateByAddingTimeInterval:[retryAfterNum doubleValue]];
  } else {
    retryAfter =
      [[HCRelationExecutor dateFormatterWithPattern:HTTP_DATE_FORMAT]
        dateFromString:retryAfterHdrVal];
  }
  return retryAfter;
}

- (NSDate *)lastModifiedDateFromResponse:(NSHTTPURLResponse *)httpResponse {
  NSString *lastModifiedStr = [[httpResponse allHeaderFields] objectForKey:@"last-modified"];
  if (lastModifiedStr) {
    return [[HCRelationExecutor dateFormatterWithPattern:HTTP_DATE_FORMAT]
              dateFromString:lastModifiedStr];
  }
  return nil;
}

+ (NSString *)realmForAuthHeaderValue:(NSString *)authHeaderVal {
  NSError *error = nil;
  NSRegularExpression *regex =
    [NSRegularExpression
      regularExpressionWithPattern:@"realm=\"([^\"]+)\""
                           options:NSRegularExpressionCaseInsensitive
                             error:&error];
  NSTextCheckingResult *result =
    [regex firstMatchInString:authHeaderVal
                      options:0
                        range:NSMakeRange(0, [authHeaderVal length])];
  NSString *realmVal = nil;
  if (result) {
    NSRange realmValRange = [result rangeAtIndex:1];
    realmVal = [authHeaderVal substringWithRange:realmValRange];
  }
  return realmVal;
}

+ (NSString *)schemeForAuthHeaderValue:(NSString *)authHeaderVal {
  NSArray *substrings = [authHeaderVal componentsSeparatedByString:@" "];
  NSString *scheme = nil;
  if (substrings) {
    scheme = [substrings objectAtIndex:0];
  }
  return scheme;
}

- (void)processResponse:(AFHTTPRequestOperation *)op
       successProcessor:(void (^)(void))successProcessor
            redirection:(HCRedirectionBlk)redirection
      conflictProcessor:(void (^)(void))conflictProcessor
            clientError:(HCClientErrorBlk)clientErr
 authenticationRequired:(HCAuthReqdErrorBlk)authRequired
            serverError:(HCServerErrorBlk)serverErr
       unavailableError:(HCServerUnavailableBlk)unavailableErr {
  id response = [op response];
  if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
    NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
    NSDictionary *headers = [httpResp allHeaderFields];
    NSInteger respCode = [httpResp statusCode];
    NSString *retryAfterHdrVal = [headers objectForKey:@"retry-after"];
    if (respCode == 503) {
      NSDate *retryAfter = nil;
      if (retryAfterHdrVal) {
        retryAfter = [self dateFromRetryAfterHeaderVal:retryAfterHdrVal];
      }
      unavailableErr(retryAfter, httpResp);
    } else if (respCode < 300 && respCode >= 200) {
      successProcessor();
    } else if (respCode < 400 && respCode >= 300) {
      /*
       * There's a good reason why we don't explicitly check for 301, and that
       * is because, when encountered, 301 (and 303/302) are automatically
       * "followed" by AFNetworking, so when control reaches this function, the
       * response reflects the response AFTER having followed all redirects.  So
       * instead, for 301, we have inserted code into AFNetworking that will be
       * invoked in-between receiving the 301 response, and following the new
       * resource location; the code to be invoked is indeed the "redirection"
       * block!  So, it's possible for any of the do*** methods, in addition to
       * the normal "HC**SuccessBlk" or "HCClientErrorBlk" block being invoked,
       * so may the HCRedirectionBlk.  This would only happen for 301s.  This is
       * because of the semantics of 301; 301 = PERMANENT move; and so, we
       * actually care about the resource's new URL.  303 is temporary redirect,
       * so, we're fine with essentially ignoring it (i.e., NOT have the
       * HCRedirectionBlk be invoked) and simply let AFNetworking automatically
       * follow the redirect.
       */
      if (respCode == 304) {
        redirection(nil, NO, YES, httpResp);
      } else {
        redirection([HCUtils locationAsUrlFromResponse:httpResp], NO, NO, httpResp);
      }
    } else if (respCode < 500 && respCode >= 400) {
      if (respCode == 401) {
        HCAuthentication *auth = nil;
        NSString *wwwAuthHdrVal = [headers objectForKey:@"www-authenticate"];
        if (wwwAuthHdrVal) {
          auth = [HCAuthentication
                    authWithScheme:[HCRelationExecutor
                               schemeForAuthHeaderValue:wwwAuthHdrVal]
                             realm:[HCRelationExecutor
                               realmForAuthHeaderValue:wwwAuthHdrVal]];
        }
        authRequired(auth, httpResp);
      } else if (respCode == 409) {
        conflictProcessor();
      } else {
        clientErr(httpResp);
      }
    } else if (respCode < 600 && respCode >= 500) {
      serverErr(httpResp);
    } else {
      successProcessor(); // by default, we'll just invoke the success block (shrug)
    }
  }
}

- (NSURLRequest *(^)(NSURLConnection *, NSURLRequest *, NSURLResponse *)) newAFRedirectBlkFor301Capture:(HCRedirectionBlk)redirection {
  return ^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
    if (redirectResponse) {
      NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)redirectResponse;
      if ([httpResp statusCode] == 301) {
        redirection([HCUtils locationAsUrlFromResponse:httpResp], YES, NO, httpResp);
      }
    }
    return request;
  };
}

- (AFHTTPRequestOperationManager*)managerForGetWithTargetSerializer:(id<HCResourceSerializer>)targetSerializer
                                                    ifModifiedSince:(NSDate *)modifiedSince
                                                      authorization:(HCAuthorization *)authorization
                                                            timeout:(NSInteger)timeout
                                                        cachePolicy:(NSURLRequestCachePolicy)cachePolicy
                                                       otherHeaders:(NSDictionary *)otherHeaders {
  AFHTTPRequestOperationManager *mgr;
  if (modifiedSince) {
    NSMutableDictionary *otherHeadersMutDict =
    [NSMutableDictionary dictionaryWithDictionary:otherHeaders];
    [otherHeadersMutDict setObject:[HCUtils rfc7231StringFromDate:modifiedSince]
                            forKey:@"if-modified-since"];
    mgr = [self reqOpMgrWithResponseSerializer:targetSerializer
                                 authorization:authorization
                                       timeout:timeout
                                   cachePolicy:cachePolicy
                                  otherHeaders:otherHeadersMutDict];
  } else {
    mgr = [self reqOpMgrWithResponseSerializer:targetSerializer
                                 authorization:authorization
                                       timeout:timeout
                                   cachePolicy:cachePolicy
                                  otherHeaders:otherHeaders];
  }
  return mgr;
}

- (void)doGetInvokerForURLString:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
                requestOpManager:(AFHTTPRequestOperationManager *)mgr
                    asynchronous:(BOOL)asynchronous
                 completionQueue:(dispatch_queue_t)completionQueue
                         success:(HCGETSuccessBlk)success
                     redirection:(HCRedirectionBlk)redirection
                     clientError:(HCClientErrorBlk)clientErr
          authenticationRequired:(HCAuthReqdErrorBlk)authRequired
                     serverError:(HCServerErrorBlk)serverErr
                unavailableError:(HCServerUnavailableBlk)unavailableErr
               connectionFailure:(HCConnFailureBlk)connFailure {
  AFSuccessBlk successBlk = ^(AFHTTPRequestOperation *op, id responseObj) {
    void (^successProcessor)(void) = ^{
      HCDeserializedPair *pair = (HCDeserializedPair *)responseObj;
      NSHTTPURLResponse *resp = [op response];
      success([HCUtils locationAsUrlFromResponse:resp],
              [pair resourceModel],
              [self lastModifiedDateFromResponse:resp],
              [pair relations],
              [op response]);
    };
    [self processResponse:op
         successProcessor:successProcessor
              redirection:redirection
        conflictProcessor:nil // conflicts are not possible with HTTP GETs
              clientError:clientErr
   authenticationRequired:authRequired
              serverError:serverErr
         unavailableError:unavailableErr];
  };
  AFFailureBlk failureBlk = ^(AFHTTPRequestOperation *op, NSError *err) {
    connFailure([err code]);
  };
  NSURLRequest *request = [self requestWithOpMgr:mgr httpMethod:@"GET" URLString:URLString parameters:parameters];
  DDLogDebug(@"(doGetInvoker:) HTTP request: [%@]", request);
  AFHTTPRequestOperation *operation = [mgr HTTPRequestOperationWithRequest:request success:successBlk failure:failureBlk];
  [operation setSecurityPolicy:_afsecurityPolicy];
  [operation setRedirectResponseBlock:[self newAFRedirectBlkFor301Capture:redirection]];
  if (completionQueue) { [operation setCompletionQueue:completionQueue]; }
  if (asynchronous) {
    [[mgr operationQueue] addOperation:operation];
  } else {
    [operation start];
  }
}

#pragma mark - Executors

- (void)doGetForTargetResource:(HCResource *)targetResource
                    parameters:(NSDictionary *)parameters
               ifModifiedSince:(NSDate *)modifiedSince
              targetSerializer:(id<HCResourceSerializer>)targetSerializer
                  asynchronous:(BOOL)asynchronous
               completionQueue:(dispatch_queue_t)completionQueue
                 authorization:(HCAuthorization *)authorization
                       success:(HCGETSuccessBlk)success
                   redirection:(HCRedirectionBlk)redirection
                   clientError:(HCClientErrorBlk)clientErr
        authenticationRequired:(HCAuthReqdErrorBlk)authRequired
                   serverError:(HCServerErrorBlk)serverErr
              unavailableError:(HCServerUnavailableBlk)unavailableErr
             connectionFailure:(HCConnFailureBlk)connFailure
                       timeout:(NSInteger)timeout
                   cachePolicy:(NSURLRequestCachePolicy)cachePolicy
                  otherHeaders:(NSDictionary *)otherHeaders {
  AFHTTPRequestOperationManager *mgr = [self managerForGetWithTargetSerializer:targetSerializer
                                                               ifModifiedSince:modifiedSince
                                                                 authorization:authorization
                                                                       timeout:timeout
                                                                   cachePolicy:cachePolicy
                                                                  otherHeaders:otherHeaders];
  [self doGetInvokerForURLString:[self urlForResource:targetResource forOpMgr:mgr]
                      parameters:parameters
                requestOpManager:mgr
                    asynchronous:asynchronous
                 completionQueue:completionQueue
                         success:success
                     redirection:redirection
                     clientError:clientErr
          authenticationRequired:authRequired
                     serverError:serverErr
                unavailableError:unavailableErr
               connectionFailure:connFailure];
}

- (void)doGetForURLString:(NSString *)URLString
               parameters:(NSDictionary *)parameters
          ifModifiedSince:(NSDate *)modifiedSince
         targetSerializer:(id<HCResourceSerializer>)targetSerializer
             asynchronous:(BOOL)asynchronous
          completionQueue:(dispatch_queue_t)completionQueue
            authorization:(HCAuthorization *)authorization
                  success:(HCGETSuccessBlk)success
              redirection:(HCRedirectionBlk)redirection
              clientError:(HCClientErrorBlk)clientErr
   authenticationRequired:(HCAuthReqdErrorBlk)authRequired
              serverError:(HCServerErrorBlk)serverErr
         unavailableError:(HCServerUnavailableBlk)unavailableErr
        connectionFailure:(HCConnFailureBlk)connFailure
                  timeout:(NSInteger)timeout
              cachePolicy:(NSURLRequestCachePolicy)cachePolicy
             otherHeaders:(NSDictionary *)otherHeaders {
  AFHTTPRequestOperationManager *mgr = [self managerForGetWithTargetSerializer:targetSerializer
                                                               ifModifiedSince:modifiedSince
                                                                 authorization:authorization
                                                                       timeout:timeout
                                                                   cachePolicy:cachePolicy
                                                                  otherHeaders:otherHeaders];
  [self doGetInvokerForURLString:URLString
                      parameters:parameters
                requestOpManager:mgr
                    asynchronous:asynchronous
                 completionQueue:completionQueue
                         success:success
                     redirection:redirection
                     clientError:clientErr
          authenticationRequired:authRequired
                     serverError:serverErr
                unavailableError:unavailableErr
               connectionFailure:connFailure];
}

- (void)doPostForTargetResource:(HCResource *)targetResource
             resourceModelParam:(id)resourceModelParam
                paramSerializer:(id<HCResourceSerializer>)paramSerializer
       responseEntitySerializer:(id<HCResourceSerializer>)responseEntitySerializer
                   asynchronous:(BOOL)asynchronous
                completionQueue:(dispatch_queue_t)completionQueue
                  authorization:(HCAuthorization *)authorization
                        success:(HCPOSTSuccessBlk)success
                    redirection:(HCRedirectionBlk)redirection
                    clientError:(HCClientErrorBlk)clientErr
         authenticationRequired:(HCAuthReqdErrorBlk)authRequired
                    serverError:(HCServerErrorBlk)serverErr
               unavailableError:(HCServerUnavailableBlk)unavailableErr
              connectionFailure:(HCConnFailureBlk)connFailure
                        timeout:(NSInteger)timeout
                   otherHeaders:(NSDictionary *)otherHeaders {
  AFHTTPRequestOperationManager *mgr =
    [self reqOpMgrWithRequestSerializer:paramSerializer
                     responseSerializer:responseEntitySerializer
                          authorization:authorization
                                timeout:timeout
                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                           otherHeaders:otherHeaders];
  AFSuccessBlk successBlk = ^(AFHTTPRequestOperation *op, id responseObj) {
    void (^successProcessor)(void) = ^{
      NSHTTPURLResponse *resp = [op response];
      if (responseObj) {
        HCDeserializedPair *pair = (HCDeserializedPair *)responseObj;
        success([HCUtils locationAsUrlFromResponse:resp],
                [pair resourceModel],
                [self lastModifiedDateFromResponse:resp],
                [pair relations],
                resp);
      } else {
        success([HCUtils locationAsUrlFromResponse:resp],
                nil,
                [self lastModifiedDateFromResponse:resp],
                nil,
                resp);
      }
    };
    [self processResponse:op
         successProcessor:successProcessor
              redirection:redirection
        conflictProcessor:nil // conflicts are not possible with HTTP POSTs
              clientError:clientErr
   authenticationRequired:authRequired
              serverError:serverErr
         unavailableError:unavailableErr];
  };
  AFFailureBlk failureBlk = ^(AFHTTPRequestOperation *op, NSError *err) {
    connFailure([err code]);
  };
  NSURLRequest *request = [self requestWithOpMgr:mgr
                                      httpMethod:@"POST"
                                        resource:targetResource
                                      parameters:resourceModelParam];
  DDLogDebug(@"(doPostForTargetResource:) HTTP request: [%@]", request);
  AFHTTPRequestOperation *operation =
    [mgr HTTPRequestOperationWithRequest:request
                                 success:successBlk
                                 failure:failureBlk];
  [operation setSecurityPolicy:_afsecurityPolicy];
  [operation setRedirectResponseBlock:[self newAFRedirectBlkFor301Capture:redirection]];
  if (completionQueue) { [operation setCompletionQueue:completionQueue]; }
  if (asynchronous) {
    [[mgr operationQueue] addOperation:operation];
  } else {
    [operation start];
  }
}

- (void)doPutForTargetResource:(HCResource *)targetResource
              targetSerializer:(id<HCResourceSerializer>)targetSerializer
                  asynchronous:(BOOL)asynchronous
               completionQueue:(dispatch_queue_t)completionQueue
                 authorization:(HCAuthorization *)authorization
                       success:(HCPUTSuccessBlk)success
                   redirection:(HCRedirectionBlk)redirection
                   clientError:(HCClientErrorBlk)clientErr
        authenticationRequired:(HCAuthReqdErrorBlk)authRequired
                   serverError:(HCServerErrorBlk)serverErr
              unavailableError:(HCServerUnavailableBlk)unavailableErr
                      conflict:(HCConflictBlk)conflict
             connectionFailure:(HCConnFailureBlk)connFailure
                       timeout:(NSInteger)timeout
                  otherHeaders:(NSDictionary *)otherHeaders {
  [self doPutForTargetResource:targetResource
             ifUnmodifiedSince:nil
              targetSerializer:targetSerializer
                  asynchronous:asynchronous
               completionQueue:completionQueue
                 authorization:authorization
                       success:success
                   redirection:redirection
                   clientError:clientErr
        authenticationRequired:authRequired
                   serverError:serverErr
              unavailableError:unavailableErr
                      conflict:conflict
             connectionFailure:connFailure
                       timeout:timeout
                  otherHeaders:otherHeaders];
}

- (void)doPutForTargetResource:(HCResource *)targetResource
             ifUnmodifiedSince:(NSDate *)unmodifiedSince
              targetSerializer:(id<HCResourceSerializer>)targetSerializer
                  asynchronous:(BOOL)asynchronous
               completionQueue:(dispatch_queue_t)completionQueue
                 authorization:(HCAuthorization *)authorization
                       success:(HCPUTSuccessBlk)success
                   redirection:(HCRedirectionBlk)redirection
                   clientError:(HCClientErrorBlk)clientErr
        authenticationRequired:(HCAuthReqdErrorBlk)authRequired
                   serverError:(HCServerErrorBlk)serverErr
              unavailableError:(HCServerUnavailableBlk)unavailableErr
                      conflict:(HCConflictBlk)conflict
             connectionFailure:(HCConnFailureBlk)connFailure
                       timeout:(NSInteger)timeout
                  otherHeaders:(NSDictionary *)otherHeaders {
  AFHTTPRequestOperationManager *mgr;
  if (unmodifiedSince) {
    NSMutableDictionary *otherHeadersMutDict =
      [NSMutableDictionary dictionaryWithDictionary:otherHeaders];
    [otherHeadersMutDict setObject:[HCUtils rfc7231StringFromDate:unmodifiedSince]
                            forKey:@"if-unmodified-since"];
    mgr = [self reqOpMgrWithRequestSerializer:targetSerializer
                           responseSerializer:targetSerializer
                                authorization:authorization
                                      timeout:timeout
                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                 otherHeaders:otherHeadersMutDict];
  } else  {
    mgr = [self reqOpMgrWithRequestSerializer:targetSerializer
                           responseSerializer:targetSerializer
                                authorization:authorization
                                      timeout:timeout
                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                 otherHeaders:otherHeaders];
  }
  AFSuccessBlk successBlk = ^(AFHTTPRequestOperation *op, id responseObj) {
    void (^(^processorMaker)(void (^)(NSURL *, id, NSDate *, NSDictionary *, NSHTTPURLResponse *)))(void) =
    ^(void (^processor)(NSURL *, id, NSDate *, NSDictionary *, NSHTTPURLResponse *)) {
      return (^{
        NSHTTPURLResponse *resp = [op response];
        if (responseObj) {
          HCDeserializedPair *pair = (HCDeserializedPair *)responseObj;
          processor([HCUtils locationAsUrlFromResponse:resp],
                    [pair resourceModel],
                    [self lastModifiedDateFromResponse:resp],
                    [pair relations],
                    resp);
        } else {
          processor([HCUtils locationAsUrlFromResponse:resp],
                    nil,
                    [self lastModifiedDateFromResponse:resp],
                    nil,
                    resp);
        }
      });
    };
    [self processResponse:op
         successProcessor:processorMaker(success)
              redirection:redirection
        conflictProcessor:processorMaker(conflict)
              clientError:clientErr
   authenticationRequired:authRequired
              serverError:serverErr
         unavailableError:unavailableErr];
  };
  AFFailureBlk failureBlk = ^(AFHTTPRequestOperation *op, NSError *err) {
    connFailure([err code]);
  };
  NSURLRequest *request = [self requestWithOpMgr:mgr
                                      httpMethod:@"PUT"
                                        resource:targetResource
                                      parameters:[targetResource model]];
  DDLogDebug(@"(doPutForTargetResource:) HTTP request: [%@]", request);
  AFHTTPRequestOperation *operation =
    [mgr HTTPRequestOperationWithRequest:request
                                 success:successBlk
                                 failure:failureBlk];
  [operation setSecurityPolicy:_afsecurityPolicy];
  [operation setRedirectResponseBlock:[self newAFRedirectBlkFor301Capture:redirection]];
  if (completionQueue) { [operation setCompletionQueue:completionQueue]; }
  if (asynchronous) {
    [[mgr operationQueue] addOperation:operation];
  } else {
    [operation start];
  }
}

- (void)doDeleteOfTargetResource:(HCResource *)targetResource
         wouldBeTargetSerializer:(id<HCResourceSerializer>)wouldBeTargetSerializer
                    asynchronous:(BOOL)asynchronous
                 completionQueue:(dispatch_queue_t)completionQueue
                   authorization:(HCAuthorization *)authorization
                         success:(HCDELETESuccessBlk)success
                     redirection:(HCRedirectionBlk)redirection
                     clientError:(HCClientErrorBlk)clientErr
          authenticationRequired:(HCAuthReqdErrorBlk)authRequired
                     serverError:(HCServerErrorBlk)serverErr
                unavailableError:(HCServerUnavailableBlk)unavailableErr
                        conflict:(HCConflictBlk)conflict
               connectionFailure:(HCConnFailureBlk)connFailure
                         timeout:(NSInteger)timeout
                    otherHeaders:(NSDictionary *)otherHeaders {
  [self doDeleteOfTargetResource:targetResource
               ifUnmodifiedSince:nil
         wouldBeTargetSerializer:wouldBeTargetSerializer
                    asynchronous:asynchronous
                 completionQueue:completionQueue
                   authorization:authorization
                         success:success
                     redirection:redirection
                     clientError:clientErr
          authenticationRequired:authRequired
                     serverError:serverErr
                unavailableError:unavailableErr
                        conflict:conflict
               connectionFailure:connFailure
                         timeout:timeout
                    otherHeaders:otherHeaders];
}

- (void)doDeleteOfTargetResource:(HCResource *)targetResource
               ifUnmodifiedSince:(NSDate *)unmodifiedSince
         wouldBeTargetSerializer:(id<HCResourceSerializer>)wouldBeTargetSerializer
                    asynchronous:(BOOL)asynchronous
                 completionQueue:(dispatch_queue_t)completionQueue
                   authorization:(HCAuthorization *)authorization
                         success:(HCDELETESuccessBlk)success
                     redirection:(HCRedirectionBlk)redirection
                     clientError:(HCClientErrorBlk)clientErr
          authenticationRequired:(HCAuthReqdErrorBlk)authRequired
                     serverError:(HCServerErrorBlk)serverErr
                unavailableError:(HCServerUnavailableBlk)unavailableErr
                        conflict:(HCConflictBlk)conflict
               connectionFailure:(HCConnFailureBlk)connFailure
                         timeout:(NSInteger)timeout
                    otherHeaders:(NSDictionary *)otherHeaders {
  AFHTTPRequestOperationManager *mgr;
  if (unmodifiedSince) {
    NSMutableDictionary *otherHeadersMutDict =
    [NSMutableDictionary dictionaryWithDictionary:otherHeaders];
    [otherHeadersMutDict setObject:[HCUtils rfc7231StringFromDate:unmodifiedSince]
                            forKey:@"if-unmodified-since"];
    mgr = [self reqOpMgrWithResponseSerializer:wouldBeTargetSerializer
                                 authorization:authorization
                                       timeout:timeout
                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                  otherHeaders:otherHeadersMutDict];
  } else  {
    mgr = [self reqOpMgrWithResponseSerializer:wouldBeTargetSerializer
                                 authorization:authorization
                                       timeout:timeout
                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                  otherHeaders:otherHeaders];
  }
  AFSuccessBlk successBlk = ^(AFHTTPRequestOperation *op, id responseObj) {
    void (^conflictProcessor)(void) = ^ {
      NSHTTPURLResponse *resp = [op response];
      if (responseObj) {
        HCDeserializedPair *pair = (HCDeserializedPair *)responseObj;
        conflict([HCUtils locationAsUrlFromResponse:resp],
                 [pair resourceModel],
                 [self lastModifiedDateFromResponse:resp],
                 [pair relations],
                 resp);
      } else {
        conflict([HCUtils locationAsUrlFromResponse:resp],
                 nil,
                 [self lastModifiedDateFromResponse:resp],
                 nil,
                 resp);
      }
    };
    [self processResponse:op
         successProcessor:^{ success([op response]); }
              redirection:redirection
        conflictProcessor:conflictProcessor
              clientError:clientErr
   authenticationRequired:authRequired
              serverError:serverErr
         unavailableError:unavailableErr];
  };
  AFFailureBlk failureBlk = ^(AFHTTPRequestOperation *op, NSError *err) {
    connFailure([err code]);
  };
  NSURLRequest *request = [self requestWithOpMgr:mgr
                                      httpMethod:@"DELETE"
                                        resource:targetResource
                                      parameters:nil];
  DDLogDebug(@"(doDeleteOfTargetResource:) HTTP request: [%@]", request);
  AFHTTPRequestOperation *operation =
    [mgr HTTPRequestOperationWithRequest:request
                                 success:successBlk
                                 failure:failureBlk];
  [operation setSecurityPolicy:_afsecurityPolicy];
  [operation setRedirectResponseBlock:[self newAFRedirectBlkFor301Capture:redirection]];
  if (completionQueue) { [operation setCompletionQueue:completionQueue]; }
  if (asynchronous) {
    [[mgr operationQueue] addOperation:operation];
  } else {
    [operation start];
  }
}

@end
