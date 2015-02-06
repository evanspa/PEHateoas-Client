//
//  HCRelationTests.m
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

#import "HCRelation.h"
#import <Kiwi/Kiwi.h>

SPEC_BEGIN(HCRelationSpec)

describe(@"HCRelation", ^{
    __block HCRelation *relation;

    beforeEach(^{
        relation = nil;
      });

    it(@"works using sane inputs to its designated initializer", ^{
        [relation shouldBeNil]; // sanity check
        HCResource *subjectRes =
          [[HCResource alloc]
            initWithMediaType:[HCMediaType MediaTypeFromString:@"text/plain"]
                          uri:[NSURL URLWithString:@"https://ex.com/api"]];
        HCResource *targetRes =
          [[HCResource alloc]
            initWithMediaType:[HCMediaType MediaTypeFromString:@"text/plain"]
                          uri:[NSURL URLWithString:@"https://ex.com/users"]];
        relation = [[HCRelation alloc] initWithName:@"http://add-user"
                                    subjectResource:subjectRes
                                     targetResource:targetRes];
        [[relation subject] shouldNotBeNil];
        [[[relation name] should] equal:@"http://add-user"];

        // equality checks
        [[[relation subject] should]
          equal:[[HCResource alloc]
                  initWithMediaType:[HCMediaType MediaTypeFromString:@"text/plain"]
                                uri:[NSURL URLWithString:@"https://ex.com/api"]]];
        [[[relation subject] shouldNot]
          equal:[[HCResource alloc]
                  initWithMediaType:[HCMediaType MediaTypeFromString:@"text/html"]
                                uri:[NSURL URLWithString:@"https://ex.com/api"]]];
        [[[relation subject] shouldNot]
          equal:[[HCResource alloc]
                  initWithMediaType:[HCMediaType MediaTypeFromString:@"text/plain"]
                                uri:[NSURL URLWithString:@"https://ex.us/api"]]];
      });
  });

SPEC_END
