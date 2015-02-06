//
//  HCMediaTypeTests.m
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

#import "HCMediaType.h"
#import <Kiwi/Kiwi.h>

SPEC_BEGIN(HCMediaTypeSpec)

describe(@"HCMediaType", ^{
    __block HCMediaType *mediaType;

    context(@"Normal usage", ^{

        beforeEach(^{
            mediaType = nil;
          });

        it(@"works when constructed with its full initializer with non-nils", ^{
            [mediaType shouldBeNil]; // sanity check
            mediaType = [[HCMediaType alloc] initWithType:@"application"
                                                  subType:@"vnd.ex.com"
                                                  version:@"1.2.1"
                                                   format:@"edn"];
            [mediaType shouldNotBeNil];
            [[[mediaType type] should] equal:@"application"];
            [[[mediaType subType] should] equal:@"vnd.ex.com"];
            [[[mediaType version] should] equal:@"1.2.1"];
            [[[mediaType format] should] equal:@"edn"];
            [[[mediaType description] should]
              equal:@"application/vnd.ex.com-v1.2.1+edn"];
          });

        it(@"works when constructed with its full initializer with version nil", ^{
            [mediaType shouldBeNil]; // sanity check
            mediaType = [[HCMediaType alloc] initWithType:@"application"
                                                  subType:@"vnd.ex.com"
                                                  version:nil
                                                   format:@"edn"];
            [mediaType shouldNotBeNil];
            [[[mediaType type] should] equal:@"application"];
            [[[mediaType subType] should] equal:@"vnd.ex.com"];
            [[mediaType version] shouldBeNil];
            [[[mediaType format] should] equal:@"edn"];
            [[[mediaType description] should]
              equal:@"application/vnd.ex.com+edn"];
          });

        it(@"works when constructed with its full initializer with format nil", ^{
            [mediaType shouldBeNil]; // sanity check
            mediaType = [[HCMediaType alloc] initWithType:@"application"
                                                  subType:@"vnd.ex.com"
                                                  version:@"3.1.0"
                                                   format:nil];
            [mediaType shouldNotBeNil];
            [[[mediaType type] should] equal:@"application"];
            [[[mediaType subType] should] equal:@"vnd.ex.com"];
            [[[mediaType version] should] equal:@"3.1.0"];
            [[mediaType format] shouldBeNil];
            [[[mediaType description] should]
              equal:@"application/vnd.ex.com-v3.1.0"];
          });

        it(@"works when constructed with its simpler initializer", ^{
            [mediaType shouldBeNil]; // sanity check
            mediaType = [[HCMediaType alloc] initWithType:@"text"
                                                  subType:@"plain"];
            [mediaType shouldNotBeNil];
            [[[mediaType type] should] equal:@"text"];
            [[[mediaType subType] should] equal:@"plain"];
            [[[mediaType description] should] equal:@"text/plain"];
          });

        it(@"works when constructed using the convenience factory function", ^{
            [mediaType shouldBeNil]; // sanity check
            mediaType = [HCMediaType MediaTypeFromString:@"image/png"];
            [mediaType shouldNotBeNil];
            [[[mediaType type] should] equal:@"image"];
            [[[mediaType subType] should] equal:@"png"];
            [[[mediaType description] should] equal:@"image/png"];
          });

        it(@"works when constructed using the convenience factory function \
using lousy inputs", ^{
            [mediaType shouldBeNil]; // sanity check
            mediaType = [HCMediaType MediaTypeFromString:@"image"];
            [mediaType shouldNotBeNil];
            [[[mediaType type] should] equal:@"image"];
            [[mediaType subType] shouldBeNil];
          });

        it(@"works with equality testing", ^{
            mediaType = [HCMediaType MediaTypeFromString:@"image/png"];
            HCMediaType *mt1 = [HCMediaType MediaTypeFromString:@"text/plain"];
            HCMediaType *mt2 = [HCMediaType MediaTypeFromString:@"image/jpeg"];
            HCMediaType *mt3 = [HCMediaType MediaTypeFromString:@"image/png"];
            HCMediaType *mt4 = [HCMediaType MediaTypeFromString:@"other/png"];
            [[mediaType shouldNot] equal:mt1];
            [[mediaType shouldNot] equal:mt2];
            [[mediaType should] equal:mt3];
            [[mediaType shouldNot] equal:mt4];
            [[[[HCMediaType alloc] initWithType:nil subType:nil] should]
              equal:[[HCMediaType alloc] initWithType:nil subType:nil]];
          });
      });
  });

SPEC_END
