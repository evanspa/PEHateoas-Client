//
//  NSURLRequest+HCAdditions.m
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

#import "NSURLRequest+HCAdditions.h"

@implementation NSURLRequest (HCAdditions)

#pragma mark - NSObject protocol

- (NSString *)description {
  NSString *desc = [NSString stringWithFormat:@"Method: [%@].  \
URL: [%@].  Headers: [", [self HTTPMethod], [self URL]];
  NSDictionary *headers = [self allHTTPHeaderFields];
  __block NSString *headersStr = @"";
  __block int count = 0;
  [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    if (count > 0) {
      headersStr = [NSString stringWithFormat:@"%@, ", headersStr];
    }
    headersStr = [NSString stringWithFormat:@"%@{%@ : %@}", headersStr, key, obj];
    count++;
  }];
  return [NSString stringWithFormat:@"%@%@].", desc, headersStr];
}

@end
