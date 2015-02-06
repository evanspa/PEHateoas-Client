//
//  HCCharset.m
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

@implementation HCCharset {
  NSStringEncoding _encoding;
  NSString *_description;
}

#pragma mark - Initializers

- (id)initWithEncoding:(NSStringEncoding)encoding
           description:(NSString *)description {
  self = [super init];
  if (self) {
    _encoding = encoding;
    _description = description;
  }
  return self;
}

#pragma mark - NSObject

- (NSString *)description {
  return _description;
}

- (BOOL)isEqual:(id)object {
  if (self == object) {
    return YES;
  }
  if (![object isKindOfClass:[HCCharset class]]) {
    return NO;
  }
  return [self isEqualToCharset:(HCCharset *)object];
}

- (NSUInteger)hash {
  return [self encoding];
}

#pragma mark - Equality

- (BOOL)isEqualToCharset:(HCCharset *)charset {
  if (!charset) {
    return NO;
  }
  return [self encoding] == [charset encoding];
}

#pragma mark - Class methods

+ (HCCharset *)UTF8 {
  return [[HCCharset alloc] initWithEncoding:NSUTF8StringEncoding
                                 description:@"UTF-8"];
}

+ (HCCharset *)Latin1 {
  return [[HCCharset alloc] initWithEncoding:NSISOLatin1StringEncoding
                                 description:@"ISO-8859-1"];
}

@end
