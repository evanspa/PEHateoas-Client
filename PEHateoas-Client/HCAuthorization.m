//
//  HCAuthorization.m
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

#import "HCAuthorization.h"

@implementation HCAuthorization

#pragma mark - Initializers

- (id)initWithAuthScheme:(NSString *)authScheme
              authParams:(NSDictionary *)authParams {
  self = [super init];
  if (self) {
    _authScheme = authScheme;
    _authParams = authParams;
  }
  return self;
}

#pragma mark - Equality

- (BOOL)isEqualToAuthorization:(HCAuthorization *)auth {
  if (!auth) {
    return NO;
  }
  BOOL haveEqualSchemes = [[self authScheme] isEqualToString:[auth authScheme]];
  BOOL haveEqualParams = [[self authParams] isEqualToDictionary:[auth authParams]];
  return haveEqualSchemes && haveEqualParams;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
  if (self == object) {
    return YES;
  }
  if (![object isKindOfClass:[HCAuthorization class]]) {
    return NO;
  }
  return [self isEqualToAuthorization:(HCAuthorization *)object];
}

- (NSUInteger)hash {
  return [[self authScheme] hash] ^ [[self authParams] hash];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"Authorization scheme: [%@], auth \
params: [%@]", [self authScheme], [self authParams]];
}

#pragma mark - Factory Functions

+ (HCAuthorization *)authWithScheme:(NSString *)authScheme
                singleAuthParamName:(NSString *)paramName
                     authParamValue:(NSString *)paramValue {
  return [[HCAuthorization alloc]
          initWithAuthScheme:authScheme
                  authParams:[NSMutableDictionary
                              dictionaryWithObject:paramValue
                                           forKey:paramName]];
}

@end
