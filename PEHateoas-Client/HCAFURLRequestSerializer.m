//
//  HCAFURLRequestSerializer.m
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

#import "HCAFURLRequestSerializer.h"
#import "HCLogging.h"
#import "HCMediaType.h"
#import "HCCharset.h"
#import "HCAuthorization.h"
#import "HCResourceSerializer.h"

@implementation HCAFURLRequestSerializer {
  HCMediaType *_accept;
  HCCharset *_acceptCharset;
  NSString *_acceptLang;
  HCAuthorization *_authorization;
  id<HCResourceSerializer> _hcserializer;
  NSInteger _timeout;
  NSDictionary *_otherHeaders;
  NSURLRequestCachePolicy _cachePolicy;
}

#pragma mark - Initializers

- (id)initWithAccept:(HCMediaType *)accept
       acceptCharset:(HCCharset *)acceptCharset
      acceptLanguage:(NSString *)acceptLang
       authorization:(HCAuthorization *)authorization
        hcserializer:(id<HCResourceSerializer>)hcserializer
             timeout:(NSInteger)timeout
         cachePolicy:(NSURLRequestCachePolicy)cachePolicy
        otherHeaders:(NSDictionary *)otherHeaders {
  self = [super init];
  if (self) {
    _accept = accept;
    _acceptCharset = acceptCharset;
    _acceptLang = acceptLang;
    _authorization = authorization;
    _hcserializer = hcserializer;
    _timeout = timeout;
    _cachePolicy = cachePolicy;
    _otherHeaders = otherHeaders;
  }
  return self;
}

- (id)initWithAccept:(HCMediaType *)accept
       acceptCharset:(HCCharset *)acceptCharset
      acceptLanguage:(NSString *)acceptLang
       authorization:(HCAuthorization *)authorization
             timeout:(NSInteger)timeout
         cachePolicy:(NSURLRequestCachePolicy)cachePolicy
        otherHeaders:(NSDictionary *)otherHeaders {
  return [self initWithAccept:accept
                acceptCharset:acceptCharset
               acceptLanguage:acceptLang
                authorization:authorization
                 hcserializer:nil
                      timeout:timeout
                  cachePolicy:cachePolicy
                 otherHeaders:otherHeaders];
}

#pragma mark - AFURLRequestSerialization protocol

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               withParameters:(NSDictionary *)parameters
                                        error:(NSError *__autoreleasing *)error {
  NSMutableURLRequest *newRequest = [request mutableCopy];
  NSString *acceptHdrVal =
    [NSString stringWithFormat:@"%@;q=1.0,ISO-8859-1;q=0",
              [_accept description]];
  [newRequest setValue:acceptHdrVal forHTTPHeaderField:@"Accept"];
  [newRequest setValue:_acceptLang forHTTPHeaderField:@"Accept-Language"];
  [newRequest setValue:[_acceptCharset description]
    forHTTPHeaderField:@"Accept-Charset"];
  if (_authorization) {
    NSDictionary *authParamsDict = [_authorization authParams];
    NSArray *authParamNames =
      [[authParamsDict allKeys]
        sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSInteger numEntries = [authParamsDict count];
    NSMutableString *authParamsStr = [[NSMutableString alloc] init];
    for (int i = 0; i < numEntries; i++) {
      NSString *paramName = [authParamNames objectAtIndex:i];
      [authParamsStr appendFormat:@"%@=\"%@\"", paramName,
        [authParamsDict objectForKey:paramName]];
      if (i + 1 < numEntries) {
        [authParamsStr appendString:@","];
      }
    }
    NSString *authHdrVal =
      [NSString stringWithFormat:@"%@ %@", [_authorization authScheme], authParamsStr];
    [newRequest setValue:authHdrVal forHTTPHeaderField:@"Authorization"];
  }
  if (_otherHeaders) {
    [_otherHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [newRequest setValue:obj forHTTPHeaderField:key];
      }];
  }
  [newRequest setTimeoutInterval:_timeout];
  [newRequest setCachePolicy:_cachePolicy];
  if (_hcserializer) {
    NSString *contentTypeHdrVal =
      [NSString stringWithFormat:@"%@;charset=%@",
                [[_hcserializer mediaType] description],
                [_hcserializer requestSerializationCharacterSet]];
    [newRequest setValue:contentTypeHdrVal
      forHTTPHeaderField:@"Content-Type"];
    NSData *data = [_hcserializer serializeResourceModelToTextData:parameters];
    DDLogDebug(@"inside HCAURLRequestSerializer.m, requestBySerializingRequest:withParameters:error:, \
HTTP request body: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    [newRequest setHTTPBody:data];
  }
  // With my fuel purchase app, I found that for PUT requests, iOS was including
  // a "If-Modified-Since" header, which was bad.  I don't know why it was doing
  // this; I think maybe because my REST API is including a "Location" header in
  // PUT responses; I dunno.  So, adding this to protect against this behavior.
  if (![[newRequest HTTPMethod] isEqualToString:@"GET"]) {
    [newRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
  }
  return newRequest;
}

@end
