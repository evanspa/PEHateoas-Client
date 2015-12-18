//
//  HCAFURLRequestSerializerTests.m
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
#import "HCFakeResourceSerializer.h"
#import "HCAuthorization.h"
#import "HCMediaType.h"
#import "HCCharset.h"
#import <Kiwi/Kiwi.h>

SPEC_BEGIN(HCAFURLRequestSerializerSpec)

describe(@"HCAFURLRequestSerializer", ^{
    __block HCAFURLRequestSerializer *reqSerializer;
    __block NSMutableURLRequest *existingRequest;

    beforeEach(^{
        reqSerializer = nil;
        existingRequest = [[NSMutableURLRequest alloc] init];
      });

    it(@"works in the simple case whereby the request will not have an entity \
body and thus will not require a content-type header and an HC serializer.", ^{
         reqSerializer =
           [[HCAFURLRequestSerializer alloc]
             initWithAccept:[HCMediaType MediaTypeFromString:@"application/json"]
              acceptCharset:[HCCharset UTF8]
             acceptLanguage:@"en-US"
              authorization:[HCAuthorization authWithScheme:@"TokenScheme"
                                        singleAuthParamName:@"p1"
                                             authParamValue:@"v1"]
                    timeout:60
                cachePolicy:NSURLRequestUseProtocolCachePolicy
               otherHeaders:@{@"test-hdr" : @"test-hdr-val"}];
         [reqSerializer shouldNotBeNil];
         NSURLRequest *serializedRequest =
           [reqSerializer requestBySerializingRequest:existingRequest
                                       withParameters:nil
                                                error:nil];
         [serializedRequest shouldNotBeNil];
         [[serializedRequest valueForHTTPHeaderField:@"Accept"] shouldNotBeNil];
         [[[serializedRequest valueForHTTPHeaderField:@"Accept"] should]
           equal:@"application/json;q=1.0,ISO-8859-1;q=0"];
         [[serializedRequest valueForHTTPHeaderField:@"Accept-Language"]
           shouldNotBeNil];
         [[[serializedRequest valueForHTTPHeaderField:@"Accept-Language"] should]
           equal:@"en-US"];
         [[serializedRequest valueForHTTPHeaderField:@"Accept-Charset"]
           shouldNotBeNil];
         [[[serializedRequest valueForHTTPHeaderField:@"Accept-Charset"] should]
           equal:@"UTF-8"];
         [[[serializedRequest valueForHTTPHeaderField:@"test-hdr"] should]
           equal:@"test-hdr-val"];
         [[serializedRequest valueForHTTPHeaderField:@"Content-Type"]
           shouldBeNil];
         [[[serializedRequest valueForHTTPHeaderField:@"Authorization"] should]
           equal:@"TokenScheme p1=\"v1\""];
         NSData *actualReqBody = [serializedRequest HTTPBody];
         [actualReqBody shouldBeNil];
       });

    it(@"works in the complex case whereby the request will have an entity \
body and thus will require a content-type header and an HC serializer.", ^{
        NSString *fakeReqBody = @"<something>some-data</something>";
        NSData *fakeReqBodyData =
          [fakeReqBody dataUsingEncoding:NSISOLatin1StringEncoding];
        HCFakeResourceSerializer *fakeResSerializer =
          [[HCFakeResourceSerializer alloc]
            initWithMediaType:[HCMediaType MediaTypeFromString:@"application/xml"]
                      charset:[HCCharset Latin1]
serializersForEmbeddedResources:@{}
  actionsForEmbeddedResources:@{}];
        [fakeResSerializer setFakeSerializationResult:fakeReqBodyData];
        reqSerializer =
          [[HCAFURLRequestSerializer alloc]
            initWithAccept:[HCMediaType MediaTypeFromString:@"application/json"]
             acceptCharset:[HCCharset UTF8]
            acceptLanguage:@"en-US"
             authorization:[[HCAuthorization alloc]
                              initWithAuthScheme:@"TknScheme"
                                      authParams:@{@"p1" : @"v1",
                                                   @"p2" : @"v2",
                                                   @"p3" : @"v3"}]
              hcserializer:fakeResSerializer
                   timeout:60
               cachePolicy:NSURLRequestUseProtocolCachePolicy
              otherHeaders:nil];
        [reqSerializer shouldNotBeNil];

        NSURLRequest *serializedRequest =
          [reqSerializer requestBySerializingRequest:existingRequest
                                      withParameters:nil
                                               error:nil];
        [serializedRequest shouldNotBeNil];
        [[serializedRequest valueForHTTPHeaderField:@"Accept"] shouldNotBeNil];
        [[[serializedRequest valueForHTTPHeaderField:@"Accept"] should]
          equal:@"application/json;q=1.0,ISO-8859-1;q=0"];
        [[serializedRequest valueForHTTPHeaderField:@"Accept-Language"]
          shouldNotBeNil];
        [[[serializedRequest valueForHTTPHeaderField:@"Accept-Language"] should]
          equal:@"en-US"];
        [[serializedRequest valueForHTTPHeaderField:@"Accept-Charset"]
          shouldNotBeNil];
        [[[serializedRequest valueForHTTPHeaderField:@"Accept-Charset"] should]
          equal:@"UTF-8"];
        [[serializedRequest valueForHTTPHeaderField:@"Content-Type"]
          shouldNotBeNil];
        [[[serializedRequest valueForHTTPHeaderField:@"Content-Type"] should]
          equal:@"application/xml;charset=ISO-8859-1"];
        [[[serializedRequest valueForHTTPHeaderField:@"Authorization"] should]
          equal:@"TknScheme p1=\"v1\",p2=\"v2\",p3=\"v3\""];
        NSData *actualReqBody = [serializedRequest HTTPBody];
        [actualReqBody shouldNotBeNil];
        NSString *actualReqBodyStr =
          [[NSString alloc] initWithData:actualReqBody
                                encoding:NSISOLatin1StringEncoding];
        [actualReqBodyStr shouldNotBeNil];
        [[actualReqBodyStr should] equal:@"<something>some-data</something>"];
      });

  });

SPEC_END
