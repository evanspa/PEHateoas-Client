//
//  HCAFURLResponseSerializeTests.m
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

#import "HCAFURLResponseSerializer.h"
#import "HCFakeResourceSerializer.h"
#import "HCRelation.h"
#import <Kiwi/Kiwi.h>

SPEC_BEGIN(HCAFURLResponseSerializerSpec)

describe(@"HCAFURLResponseSerializer", ^{
    __block HCAFURLResponseSerializer *respSerializer;
    __block HCFakeResourceSerializer *fakeResSerializer;

    beforeAll(^{
        fakeResSerializer = [[HCFakeResourceSerializer alloc]
                              initWithMediaType:[HCMediaType MediaTypeFromString:@"application/json"]
                                        charset:[HCCharset Latin1]
                serializersForEmbeddedResources:@{}
                    actionsForEmbeddedResources:@{}];
      });

    beforeEach(^{
        respSerializer = nil;
      });

    it(@"works in the case of having a non-nil HTTP response body", ^{
        HCMediaType *appJsonMediaType =
          [HCMediaType MediaTypeFromString:@"application/json"];
        NSDictionary *relations = @{
          @"http://add-user" :
          [[HCRelation alloc]
            initWithName:@"http://add-user"
            subjectResource:[[HCResource alloc]
                              initWithMediaType:appJsonMediaType
                                            uri:[NSURL URLWithString:@"/api"]]
            targetResource:[[HCResource alloc]
                             initWithMediaType:appJsonMediaType
                                           uri:[NSURL URLWithString:@"/users"]]],
          @"self" :
          [[HCRelation alloc]
            initWithName:@"self"
            subjectResource:[[HCResource alloc]
                              initWithMediaType:appJsonMediaType
                                            uri:[NSURL URLWithString:@"/api"]]
            targetResource:[[HCResource alloc]
                             initWithMediaType:appJsonMediaType
                                           uri:[NSURL URLWithString:@"/users"]]]
        };
        HCDeserializedPair *fakePair =
          [[HCDeserializedPair alloc]
            initWithResourceModel:@"\"something\": \"some-data\""
                        relations:relations];
        [fakeResSerializer setFakeDeserializedPairResult:fakePair];

        respSerializer = [[HCAFURLResponseSerializer alloc]
                           initWithHCSerializer:fakeResSerializer];

        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc]
                                        initWithURL:nil
                                         statusCode:200
                                        HTTPVersion:nil
                                       headerFields:nil];
        id responseObj =
          [respSerializer responseObjectForResponse:response data:nil error:nil];
        [responseObj shouldNotBeNil];
        [[theValue([responseObj isKindOfClass:[HCDeserializedPair class]])
                  should] beYes];
        HCDeserializedPair *pair = (HCDeserializedPair *)responseObj;
        id respResModel = [pair resourceModel];
        [respResModel shouldNotBeNil];
        [respResModel isKindOfClass:[NSString class]];
        NSString *respResModelStr = (NSString *)respResModel;
        [[respResModelStr should] equal:@"\"something\": \"some-data\""];
        [[pair relations] shouldNotBeNil];
        [[theValue([[pair relations] count]) should] equal:theValue(2)];
      });
  });

SPEC_END
