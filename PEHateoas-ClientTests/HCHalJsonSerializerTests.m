//
//  HCHalJsonSerializerTests.m
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

#import "HCHalJsonSerializer.h"
#import "HCRelation.h"
#import "HCTestUtils.h"
#import "HCMediaType.h"
#import "HCCharset.h"
#import "HCDeserializedPair.h"
#import <PEObjc-Commons/PEUtils.h>
#import <Kiwi/Kiwi.h>

SPEC_BEGIN(HCHalJsonSerializerSpec)

describe(@"HCHalJsonSerializer", ^{
    __block HCHalJsonSerializer *halJsonSerializer;

    beforeAll(^{
        halJsonSerializer = [[HCHalJsonSerializer alloc]
                              initWithMediaType:[HCMediaType MediaTypeFromString:@"application/json"]
                                        charset:[HCCharset UTF8]
                serializersForEmbeddedResources:@{}
                    actionsForEmbeddedResources:@{}];
      });

    void (^relationsTester)(HCDeserializedPair *,
                            NSArray *) = ^(HCDeserializedPair *pair,
                                           NSArray *expectedRelations) {
      [pair shouldNotBeNil];
      NSDictionary *relations = [pair relations];
      [relations shouldNotBeNil];
      [HCTestUtils relations:relations
        shouldEqualRelations:expectedRelations];
    };

    void (^relationsTesterForJson)(NSString *,
                                   NSString *,
                                   NSString *,
                                   NSArray *) = ^(NSString *jsonResStr,
                                                  NSString *resUriStr,
                                                  NSString *resMtStr,
                                                  NSArray *expectedRelations) {
      NSURL *resUrl = [NSURL URLWithString:resUriStr];
      HCMediaType *resMt = [HCMediaType MediaTypeFromString:resMtStr];
      NSData *jsonResData = [jsonResStr dataUsingEncoding:NSUTF8StringEncoding];
      relationsTester([halJsonSerializer
                        deserializeResourceFromTextData:jsonResData
                                      resourceMediaType:resMt
                                            resourceURL:resUrl
                                           httpResponse:nil],
                      expectedRelations);
    };

    context(@"testing for serialization", ^{
        it(@"works serializing a simple NSDictionary", ^{
            NSDictionary *resModel = @{@"last_name" : @"Smith",
                                       @"first_name" : @"John",
                                       @"email" : @"jsmith@ex.com"};
            NSData *serializedResModel =
              [halJsonSerializer serializeResourceModelToTextData:resModel];
            [serializedResModel shouldNotBeNil];
            NSString *serializedResModelStr =
              [[NSString alloc] initWithData:serializedResModel
                                    encoding:NSUTF8StringEncoding];
            [serializedResModelStr shouldNotBeNil];
          });
      });

    context(@"testing for deserialization", ^{
        it(@"works parsing the resource-model using a simple resource", ^{
            NSString *jsonResStr = @"{\"last_name\": \"Smith\", \
                                      \"first_name\": \"John\", \
                                      \"email\": \"jsmith@ex.com\", \
                \"_links\": { \
                    \"self\": { \"href\": \"/users/u10391\" },  \
      \"http://update-user\": { \"href\": \"/users/u10391\",    \
                                \"type\": \"application/xml\" } \
                  } \
              }";
            NSURL *resUrl = [NSURL URLWithString:@"http://ex.com/users/u10391"];
            HCMediaType *resMt =
              [HCMediaType MediaTypeFromString:@"application/json"];
            NSData *jsonResData =
              [jsonResStr dataUsingEncoding:NSUTF8StringEncoding];
            HCDeserializedPair *pair =
              [halJsonSerializer deserializeResourceFromTextData:jsonResData
                                               resourceMediaType:resMt
                                                     resourceURL:resUrl
                                                    httpResponse:nil];
            [[[pair resourceModel] should] beKindOfClass:[NSDictionary class]];
            NSDictionary *resModel = (NSDictionary *)[pair resourceModel];
            [[resModel objectForKey:@"last_name"] shouldNotBeNil];
            [[[resModel objectForKey:@"last_name"] should] equal:@"Smith"];
            [[[resModel objectForKey:@"first_name"] should] equal:@"John"];
            [[[resModel objectForKey:@"email"] should] equal:@"jsmith@ex.com"];
          });

        it(@"works parsing relations using a simple resource", ^{
            NSString *jsonResStr = @"{\"api\": {}, \
                \"_links\": { \
                    \"self\": { \"href\": \"/users\" }, \
         \"http://add-user\": { \"href\": \"/users\", \
                                \"type\": \"application/xml\" } \
                  } \
              }";
            NSArray *expectedRelations = @[
              [HCTestUtils relationWithName:@"self"
                   subjectResourceMediaType:@"application/json"
                         subjectResourceUri:@"http://www.ex.com/api"
                    targetResourceMediaType:@"application/json"
                          targetResourceUri:@"http://www.ex.com/users"],
              [HCTestUtils relationWithName:@"http://add-user"
                   subjectResourceMediaType:@"application/json"
                         subjectResourceUri:@"http://www.ex.com/api"
                    targetResourceMediaType:@"application/xml"
                          targetResourceUri:@"http://www.ex.com/users"]];
            relationsTesterForJson(jsonResStr,
                                   @"http://www.ex.com/api",
                                   @"application/json",
                                   expectedRelations);
          });

        it(@"works parsing relations using another simple resource", ^{
            NSString *jsonResStr = @"{\"api\": {}, \
                \"_links\": { \
                    \"self\": { \"href\": \"/users\" }, \
         \"http://add-user\": { \"href\": \"/users\", \
                                \"type\": \"application/xml\" }, \
     \"http://search-users\": { \"href\": \"/users\", \
                                \"type\": \"application/json\" }, \
             \"http://help\": { \"href\": \"http://www.ex.com/app/help\", \
                                \"type\": \"text/html\" }, \
            \"http://admin\": { \"href\": \"admin\", \
                                \"type\": \"application/json\" } \
                  } \
              }";
            NSArray *expectedRelations = @[
              [HCTestUtils relationWithName:@"self"
                   subjectResourceMediaType:@"application/json"
                         subjectResourceUri:@"http://www.ex.com/api/"
                    targetResourceMediaType:@"application/json"
                          targetResourceUri:@"http://www.ex.com/users"],
              [HCTestUtils relationWithName:@"http://add-user"
                   subjectResourceMediaType:@"application/json"
                         subjectResourceUri:@"http://www.ex.com/api/"
                    targetResourceMediaType:@"application/xml"
                          targetResourceUri:@"http://www.ex.com/users"],
              [HCTestUtils relationWithName:@"http://search-users"
                   subjectResourceMediaType:@"application/json"
                         subjectResourceUri:@"http://www.ex.com/api/"
                    targetResourceMediaType:@"application/json"
                          targetResourceUri:@"http://www.ex.com/users"],
              [HCTestUtils relationWithName:@"http://help"
                   subjectResourceMediaType:@"application/json"
                         subjectResourceUri:@"http://www.ex.com/api/"
                    targetResourceMediaType:@"text/html"
                          targetResourceUri:@"http://www.ex.com/app/help"],
              [HCTestUtils relationWithName:@"http://admin"
                   subjectResourceMediaType:@"application/json"
                         subjectResourceUri:@"http://www.ex.com/api/"
                    targetResourceMediaType:@"application/json"
                          targetResourceUri:@"http://www.ex.com/api/admin"]];
            relationsTesterForJson(jsonResStr,
                                   @"http://www.ex.com/api/",
                                   @"application/json",
                                   expectedRelations);
          });
      });
  });

SPEC_END
