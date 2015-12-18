//
//  HCResource.m
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
#import "NSURL+HCAdditions.h"
#import "HCMediaType.h"

@implementation HCResource {
  HCMediaType *_mediaType;
  NSURL *_uri;
  id _model;
}

#pragma mark - Initializers

- (id)initWithMediaType:(HCMediaType *)mediaType
                    uri:(NSURL *)uri
                  model:(id)model {
  self = [super init];
  if (self) {
    _mediaType = mediaType;
    _uri = uri;
    _model = model;
  }
  return self;
}

- (id)initWithMediaType:(HCMediaType *)mediaType
                    uri:(NSURL *)uri {
  return [self initWithMediaType:mediaType uri:uri model:nil];
}

#pragma mark - Conveniences

- (instancetype)copyWithNewUri:(NSURL *)newUri {
  return [[[self class] alloc] initWithMediaType:_mediaType
                                             uri:newUri
                                           model:_model];
}

+ (instancetype)resourceWithUri:(NSURL *)url {
  return [[HCResource alloc] initWithMediaType:nil uri:url];
}

#pragma mark - Methods

- (HCResource *)ResourceByAppendingQueryString:(NSString *)queryString {
  return [[HCResource alloc]
            initWithMediaType:_mediaType
                          uri:[_uri URLByAppendingQueryString:queryString]
                        model:_model];
}

#pragma mark - Equality

- (BOOL)isEqualToResource:(HCResource *)resource {
  if (!resource) {
    return NO;
  }
  BOOL haveEqualMediaTypes = [[self mediaType]
                               isEqualToMediaType:[resource mediaType]];
  BOOL haveEqualUris = [[[self uri] absoluteString]
                         isEqualToString:[[resource uri] absoluteString]];
  return haveEqualMediaTypes && haveEqualUris;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
  if (self == object) {
    return YES;
  }
  if (![object isKindOfClass:[HCResource class]]) {
    return NO;
  }
  return [self isEqualToResource:(HCResource *)object];
}

- (NSUInteger)hash {
  return [[self mediaType] hash] ^ [[[self uri] absoluteString] hash];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"uri: [%@], mediaType: [%@]",
                   [_uri absoluteString], _mediaType];
}

@end
