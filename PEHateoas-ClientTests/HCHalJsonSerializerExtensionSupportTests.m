//
//  HCHalJsonSerializerExtensionSupportTests.m
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

#import "HCHalJsonSerializerExtensionSupport.h"
#import "DummyCarSerializer.h"
#import "DummyCarDoorSerializer.h"
#import "DummyCar.h"
#import "DummyCarDoor.h"
#import "HCUtils.h"
#import "HCMediaType.h"
#import "HCCharset.h"
#import "HCDeserializedPair.h"
#import <Kiwi/Kiwi.h>

SPEC_BEGIN(HCHalJsonSerializerExtensionSupportSpec)

__block DummyCar *car;
__block DummyCarSerializer *carSerializer;

context(@"HCHalJsonSerializerExtensionSupport", ^{
    beforeAll(^{
        NSString *doorMediaType = @"application/vnd.dummycardoor+json";
        DummyCarDoorSerializer *doorSerializer =
      [[DummyCarDoorSerializer alloc] initWithMediaType:[HCMediaType MediaTypeFromString:doorMediaType]
                                                charset:[HCCharset UTF8]
                        serializersForEmbeddedResources:@{}
                            actionsForEmbeddedResources:@{}];
        HCActionForEmbeddedResource action = ^(id resModel, id embeddedResModel) {
          [(DummyCar *)resModel addDoor:embeddedResModel];
        };
        carSerializer = [[DummyCarSerializer alloc]
                          initWithMediaType:[HCMediaType MediaTypeFromString:@"application/vnd.dummycar+json"]
                                    charset:[HCCharset UTF8]
            serializersForEmbeddedResources:@{doorMediaType : doorSerializer}
                actionsForEmbeddedResources:@{doorMediaType : action}];
      });

    beforeEach(^{
        car = [[DummyCar alloc] init];
        [car setColor:@"red"];
        [car setNumDoors:4];
      });

    it(@"Deserialization works with embedded resource", ^{
        NSString *embeddedJsonCarStr = @"{\"media-type\": \"application/vnd.dummycar+json\",\
\"location\": \"http://ex.com/cars/c123\", \
\"last-modified\": \"Sun, 07 Sep 2014 01:15:57 GMT\", \"payload\": {\
\"car-color\" : \"blue\", \
    \"car-number-of-doors\" : 2, \
    \"_links\": { \
    \"self\": { \"href\": \"/users/u10391\", \
    \"type\": \"application/json\" }}, \
    \"_embedded\": [ {\
        \"media-type\": \"application/vnd.dummycardoor+json\", \
        \"payload\": { \"door-name\": \"awesome door 1\" }}]}}";
        NSDictionary *jsonObj =
          [NSJSONSerialization JSONObjectWithData:[embeddedJsonCarStr dataUsingEncoding:NSUTF8StringEncoding]
                                          options:0
                                            error:nil];
        HCDeserializedPair *pair = [carSerializer deserializeEmbeddedResource:jsonObj];
        [[[pair resourceModel] should] beKindOfClass:[DummyCar class]];
        car = (DummyCar *)[pair resourceModel];
        [[[car color] should] equal:@"blue"];
        [[theValue([car numDoors]) should] equal:theValue(2)];
        [[[car location] should] equal:@"http://ex.com/cars/c123"];
        [[[car lastModified] should]
          equal:[HCUtils rfc7231DateFromString:@"Sun, 07 Sep 2014 01:15:57 GMT"]];
        [[[car mediaType] should] equal:[HCMediaType MediaTypeFromString:@"application/vnd.dummycar+json"]];
        NSArray *doors = [car doors];
        [[doors should] haveCountOf:1];
        DummyCarDoor *door = [doors objectAtIndex:0];
        [door shouldNotBeNil];
        [[[door doorName] should] equal:@"awesome door 1"];
      });

    it(@"Deserialization works with normal inputs", ^{
        NSString *jsonCarStr = @"{ \"car-color\" : \"blue\", \
                                   \"car-number-of-doors\" : 2, \
                                   \"_links\": { \
                                     \"self\": { \"href\": \"/users/u10391\", \
                                                 \"type\": \"application/json\" } \
                                   }}";
        NSURL *resUrl = [NSURL URLWithString:@"http://ex.com/cars/c123"];
        HCMediaType *resMt =
          [HCMediaType MediaTypeFromString:@"application/vnd.dummycar+json"];
        NSData *jsonCarData =
          [jsonCarStr dataUsingEncoding:NSUTF8StringEncoding];
        HCDeserializedPair *pair =
          [carSerializer deserializeResourceFromTextData:jsonCarData
                                       resourceMediaType:resMt
                                             resourceURL:resUrl
                                            httpResponse:nil];
        [[[pair resourceModel] should] beKindOfClass:[DummyCar class]];
        car = (DummyCar *)[pair resourceModel];
        [[[car color] should] equal:@"blue"];
        [[theValue([car numDoors]) should] equal:theValue(2)];
      });

    it(@"Serialization works with normal inputs", ^{
        NSData *serializedCar =
          [carSerializer serializeResourceModelToTextData:car];
        [serializedCar shouldNotBeNil];
        NSString *serializedCarStr =
          [[NSString alloc] initWithData:serializedCar
                                encoding:NSUTF8StringEncoding];
        [serializedCarStr shouldNotBeNil];
        [[theValue([serializedCarStr
                     rangeOfString:@"\"car-color\" : \"red\""].location)
             shouldNot] equal:theValue(NSNotFound)];
        [[theValue([serializedCarStr
                     rangeOfString:@"\"car-number-of-doors\" : 4"].location)
             shouldNot] equal:theValue(NSNotFound)];
      });
  });

SPEC_END
