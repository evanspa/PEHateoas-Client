//
//  HCUtilsTests.m
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

#import "HCUtils.h"
#import "HCTestUtils.h"
#import <Kiwi/Kiwi.h>

SPEC_BEGIN(HCUtilsSpec)

describe(@"HCUtils", ^{

    context(@"testing relsFromLocalHalJsonResource:fileName:resourceApiMediaType:", ^{
        it(@"works using normal inputs", ^{
            HCMediaType *appJsonMt = [HCMediaType MediaTypeFromString:@"application/json"];
            NSBundle *bundle = [NSBundle bundleForClass:[self class]];
            NSDictionary *rels =
              [HCUtils
                relsFromLocalHalJsonResource:bundle
                                    fileName:@"api-resource"
                        resourceApiMediaType:appJsonMt];
            [rels shouldNotBeNil];
            NSURL *apiResUri = [bundle URLForResource:@"api-resource"
                                        withExtension:@"json"];
            [HCTestUtils relations:rels
              shouldEqualRelations:@[[HCTestUtils relationWithName:@"users"
                                          subjectResourceMediaType:@"application/json"
                                                subjectResourceUri:[apiResUri absoluteString]
                                           targetResourceMediaType:@"application/json"
                                                 targetResourceUri:@"http://example.com/fp/users"],
                                     [HCTestUtils relationWithName:@"fuel-purchases"
                                          subjectResourceMediaType:@"application/json"
                                                subjectResourceUri:[apiResUri absoluteString]
                                           targetResourceMediaType:@"application/json"
                                                 targetResourceUri:@"http://example.com/fp/fuel-purchases"]]];
          });
      });

    context(@"testing doesRepresentAbsoluteURL:", ^{
        it(@"works using strings that are invalid URLs", ^{
            [[theValue([HCUtils doesRepresentAbsoluteURL:@"abc"]) should] beNo];
            [[theValue([HCUtils doesRepresentAbsoluteURL:@""]) should] beNo];
            [[theValue([HCUtils doesRepresentAbsoluteURL:nil]) should] beNo];
          });

        it(@"works using strings that are valid URLs", ^{
            [[theValue([HCUtils doesRepresentAbsoluteURL:@"http://wwww.ex.com"])
                      should] beYes];
            [[theValue([HCUtils doesRepresentAbsoluteURL:@"https://www.ex.com"])
                      should] beYes];
            [[theValue([HCUtils doesRepresentAbsoluteURL:@"HTTP://wwww.ex.com"])
                      should] beYes];
            [[theValue([HCUtils doesRepresentAbsoluteURL:@"hTTps://www.ex.com"])
                      should] beYes];
          });
      });

    void (^urlTester)(NSString *,
                      NSString *,
                      NSString *) = ^(NSString *from,
                                      NSString *enclosingResUrl,
                                      NSString *expected) {
      NSURL *url =
        [HCUtils ResourceURLFromString:from
                  enclosingResourceURL:[NSURL URLWithString:enclosingResUrl]];
      [url shouldNotBeNil];
      [[[url absoluteString] should] equal:expected];
    };

    context(@"testing ResourceURLFromString:enclosingResourceURL:", ^{
        it(@"works when the string URL is a valid absolute URL", ^{
            urlTester(@"http://www.ex.com",
                      @"http://www.test.com/users",
                      @"http://www.ex.com");
            urlTester(@"USER12034920",
                      @"http://www.test.com/users/",
                      @"http://www.test.com/users/USER12034920");
            urlTester(@"USER12034920",
                      @"http://www.test.com/users",
                      @"http://www.test.com/USER12034920");
            urlTester(@"/books",
                      @"http://www.test.com/users/",
                      @"http://www.test.com/books");
            urlTester(@"/books",
                      @"http://www.test.com/",
                      @"http://www.test.com/books");
            urlTester(@"/books",
                      @"http://www.test.com",
                      @"http://www.test.com/books");
          });
      });
  });

SPEC_END
