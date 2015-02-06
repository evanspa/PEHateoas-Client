//
//  HCResourceSerializerSupport.m
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

#import "HCResourceSerializerSupport.h"

@implementation HCResourceSerializerSupport {
  HCCharset *_requestSerializationCharacterSet;
  HCCharset *_responseSerializationCharacterSet;
}

#pragma mark - Initializers

- (id)initWithMediaType:(HCMediaType *)mediaType
charsetForRequestSerialization:(HCCharset *)reqCharset
charsetForResponseSerialization:(HCCharset *)respCharset
serializersForEmbeddedResources:(NSDictionary *)embeddedSerializers
actionsForEmbeddedResources:(NSDictionary *)actions {
  self = [super init];
  if (self) {
    _mediaType = mediaType;
    _requestSerializationCharacterSet = reqCharset;
    _responseSerializationCharacterSet = respCharset;
    _embeddedSerializers = embeddedSerializers;
    _embeddedResourceActions = actions;
  }
  return self;
}

- (id)initWithMediaType:(HCMediaType *)mediaType
                charset:(HCCharset *)charset
serializersForEmbeddedResources:(NSDictionary *)embeddedSerializers
actionsForEmbeddedResources:(NSDictionary *)actions {
  return [self initWithMediaType:mediaType
  charsetForRequestSerialization:charset
 charsetForResponseSerialization:charset
 serializersForEmbeddedResources:embeddedSerializers
     actionsForEmbeddedResources:actions];
}

#pragma mark - Serialization (model -> HTTP request entity)

- (NSData *)serializeResourceModelToTextData:(id)resourceModel {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must \
override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}

#pragma mark - Deserialization (HTTP response entity -> model+relations)

- (HCDeserializedPair *)deserializeResourceFromTextData:(NSData *)data
                                      resourceMediaType:(HCMediaType *)mediaType 
                                            resourceURL:(NSURL *)url
                                           httpResponse:(NSHTTPURLResponse *)httpResponse {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must \
override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}

- (HCDeserializedPair *)deserializeEmbeddedResource:(id)readTextData {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must \
override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}

@end
