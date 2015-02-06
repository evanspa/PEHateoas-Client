//
//  HCAuthenticationTests.m
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

#import "HCAuthentication.h"
#import <Kiwi/Kiwi.h>

SPEC_BEGIN(HCAuthenticationSpec)

describe(@"HCAuthentication", ^{
  __block HCAuthentication *authentication;

  beforeEach(^{
      authentication = nil;
    });

  it(@"works using sane inputs to its primary factory function", ^{
      [authentication shouldBeNil];
      authentication = [HCAuthentication authWithScheme:@"Basic"
                                                  realm:@"My Realm"];
      [authentication shouldNotBeNil];
      [[[authentication authScheme] should] equal:@"Basic"];
      NSDictionary *authParams = [authentication authParams];
      [authParams shouldBeNil];
    });

  it(@"works using the designated initializer", ^{
      [authentication shouldBeNil];
      authentication =
        [[HCAuthentication alloc]
          initWithAuthScheme:@"test scheme"
                       realm:@"test realm"
                  authParams:@{ @"param1" : @"value1" }];
      [authentication shouldNotBeNil];
      [[[authentication authScheme] should] equal:@"test scheme"];
      [[[authentication realm] should] equal:@"test realm"];
      [[[authentication authParams] should] equal:@{ @"param1" : @"value1" }];
    });

  it(@"test equality", ^{
      authentication =
        [[HCAuthentication alloc]
          initWithAuthScheme:@"test scheme"
                       realm:@"test realm"
                  authParams:@{ @"param1" : @"value1" }];
      HCAuthentication *auth2 =
        [[HCAuthentication alloc]
          initWithAuthScheme:@"test scheme"
                       realm:@"test realm"
                  authParams:@{ @"param1" : @"value1" }];
      [[authentication should] equal:auth2];
    });
});

SPEC_END
