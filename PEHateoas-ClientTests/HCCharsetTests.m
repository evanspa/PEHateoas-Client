//
//  HCCharsetTests.m
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

#import "HCCharset.h"
#import <Kiwi/Kiwi.h>

SPEC_BEGIN(HCCharsetSpec)

describe(@"HCCharset", ^{
    __block HCCharset *charset;

    beforeEach(^{
        charset = nil;
      });

    it(@"simply works", ^{
        [charset shouldBeNil]; // sanity check
        charset = [[HCCharset alloc] initWithEncoding:NSUTF8StringEncoding
                                          description:@"utf-8"];
        [charset shouldNotBeNil];
        [[theValue([charset encoding]) should]
          equal:theValue(NSUTF8StringEncoding)];
        [[[charset description] should] equal:@"utf-8"];

        // some equality testing
        [[charset should] equal:[HCCharset UTF8]];
        [[charset should] equal:[[HCCharset alloc]
                                  initWithEncoding:NSUTF8StringEncoding
                                       description:@"UTF-8"]];
        [[charset shouldNot] equal:[HCCharset Latin1]];
      });
  });

SPEC_END
