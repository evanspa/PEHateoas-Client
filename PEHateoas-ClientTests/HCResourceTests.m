//
//  HCResourceTests.m
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

#import "HCResource.h"
#import "HCMediaType.h"
#import <Kiwi/Kiwi.h>

SPEC_BEGIN(HCResourceSpec)

describe(@"HCResource", ^{
    __block HCResource *resource;

    beforeEach(^{
        resource = nil;
      });

    it(@"works using sane inputs to its designated initializer", ^{
        [resource shouldBeNil]; // sanity check
        HCMediaType *mt = [HCMediaType MediaTypeFromString:@"application/json"];
        resource =
          [[HCResource alloc]
            initWithMediaType:mt
                          uri:[NSURL URLWithString:@"http://example.com"]
                        model:@"\"some_key\" : \"some_data\""];
        [resource shouldNotBeNil];
        [[resource mediaType] shouldNotBeNil];
        [[[[resource mediaType] type] should] equal:@"application"];
        [[[[resource mediaType] subType] should] equal:@"json"];
        [[[resource uri] should]
          equal:[NSURL URLWithString:@"http://example.com"]];
        [[[resource model] should] equal:@"\"some_key\" : \"some_data\""];
      
      HCResource *newRes = [resource ResourceByAppendingQueryString:@"foo=bar"];
      [[[newRes uri] should]
          equal:[NSURL URLWithString:@"http://example.com?foo=bar"]];
      });

    it(@"works with equality testing", ^{
        resource =
          [[HCResource alloc]
            initWithMediaType:[HCMediaType MediaTypeFromString:@"app/json"]
                          uri:[NSURL URLWithString:@"http://example.com"]
                        model:@"\"some_key\" : \"some_data\""];
        HCResource *r1 =
          [[HCResource alloc]
            initWithMediaType:[HCMediaType MediaTypeFromString:@"app/json"]
                          uri:[NSURL URLWithString:@"http://example.com"]
                        model:@"\"some_key\" : \"some_data\""];
        HCResource *r2 =
          [[HCResource alloc]
            initWithMediaType:[HCMediaType MediaTypeFromString:@"image/png"]
                          uri:[NSURL URLWithString:@"http://example.com"]];
        HCResource *r3 =
          [[HCResource alloc]
            initWithMediaType:[HCMediaType MediaTypeFromString:@"app/json"]
                          uri:[NSURL URLWithString:@"http://otherexample.com"]];
        [[resource should] equal:r1];
        [[resource shouldNot] equal:r2];
        [[resource shouldNot] equal:r3];
      });
  });

SPEC_END
