//
//  HCAuthentication.m
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

@implementation HCAuthentication

#pragma mark - Initializers

- (id)initWithAuthScheme:(NSString *)authScheme
                   realm:(NSString *)realm
              authParams:(NSDictionary *)authParams {
  self = [super initWithAuthScheme:authScheme authParams:authParams];
  if (self) {
    _realm = realm;
  }
  return self;
}

#pragma mark - Equality

- (BOOL)isEqualToAuthentication:(HCAuthentication *)auth {
  if (!auth) {
    return NO;
  }
  BOOL haveEqualSchemes = [[self authScheme] isEqualToString:[auth authScheme]];
  BOOL haveEqualRealms = [[self realm] isEqualToString:[auth realm]];
  BOOL haveEqualParams = [self authParams] == [auth authParams] ||
    [[self authParams] isEqualToDictionary:[auth authParams]];
  return haveEqualSchemes && haveEqualRealms && haveEqualParams;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
  if (self == object) {
    return YES;
  }
  if (![object isKindOfClass:[HCAuthentication class]]) {
    return NO;
  }
  return [self isEqualToAuthentication:(HCAuthentication *)object];
}

- (NSUInteger)hash {
  return [[self authScheme] hash] ^ [[self realm] hash] ^ [[self authParams] hash];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"Authentication scheme: [%@], realm: [%@], \
auth params: [%@]", [self authScheme], [self realm], [self authParams]];
}


#pragma mark - Factory Functions

+ (HCAuthentication *)authWithScheme:(NSString *)authScheme
                               realm:(NSString *)realm {
  return [[HCAuthentication alloc] initWithAuthScheme:authScheme
                                                realm:realm
                                           authParams:nil];
}

+ (HCAuthentication *)authWithScheme:(NSString *)authScheme {
  return [HCAuthentication authWithScheme:authScheme realm:nil];
}

@end
