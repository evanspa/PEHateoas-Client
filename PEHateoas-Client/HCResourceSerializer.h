//
//  HCResourceModelSerializer.h
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

@import Foundation;
@class HCDeserializedPair;
@class HCMediaType;
@class HCCharset;

/**
 An abstraction for serializing and deserializing HTTP request and responses.
 This abstraction sits slighly above AFNetworking's URL request (and response)
 serialization protocols; the only difference is that this abstraction treats
 an HTTP response as containing 2 distinct logical parts: the entity and the set
 of relations.  This abstraction is meant to be able to deal nicely with
 hypermedia REST APIs.
 */
@protocol HCResourceSerializer <NSObject>

#pragma mark - Initializers

/**
 Creates and returns a resource serializer that can deal with text-based
 serialization.
 @param reqCharset the character set to use when serializing a model object to
 become the body of an HTTP POST or PUT request
 @param respCharset the character set to use when deserializing the HTTP
 response data into a model object / relations collection pair
 @return a new instance
 */
- (id)initWithMediaType:(HCMediaType *)mediaType
charsetForRequestSerialization:(HCCharset *)reqCharset
charsetForResponseSerialization:(HCCharset *)respCharset
serializersForEmbeddedResources:(NSDictionary *)embeddedSerializers
    actionsForEmbeddedResources:(NSDictionary *)actions;

/**
 Creates and returns a resource serializer that can deal with text-based
 serialization.
 @param charset the character set to use when doing both request and response
 serialization (for requests, serializing a model object to
 become the body of an HTTP POST or PUT request; for responses, deserializing
 the HTTP response data into a model object / relations collection pair)
 @return a new instance
*/
- (id)initWithMediaType:(HCMediaType *)mediaType
                charset:(HCCharset *)charset
serializersForEmbeddedResources:(NSDictionary *)embeddedSerializers
actionsForEmbeddedResources:(NSDictionary *)actions;

#pragma mark - Serialization (model -> HTTP request entity)

/**
 Serializes the given model object using a text-based encoding using the given
 character set name.  The returned NSData is intended to be used as the body
 of an HTTP POST or PUT request.
 @param resourceModel the model object to be serialized (to be used as the entiy
 of an HTTP POST or PUT request body)
  @return the serialized model object
 */
- (NSData *)serializeResourceModelToTextData:(id)resourceModel;

#pragma mark - Deserialization (HTTP response entity -> model+relations)

/**
 Deserializes the given text-based data into a pair object that encapsulates the
 model object and the collection of relations.  This method is to be used when
 parsing the top-level resource from an HTTP response envelop.
 @param data the raw text-based data that is the HTTP response body
 @param mediaType the media type of the resource
 @param url The resource's URL.
 @return pair object that encapsulates the deserialized resource model and
 relations collection
 */
- (HCDeserializedPair *)deserializeResourceFromTextData:(NSData *)data
                                      resourceMediaType:(HCMediaType *)mediaType
                                            resourceURL:(NSURL *)url
                                           httpResponse:(NSHTTPURLResponse *)httpResponse;

/**
 Should be used when deserializing an embedded resource.
 */
- (HCDeserializedPair *)deserializeEmbeddedResource:(id)readTextData;

#pragma mark - Properties

@property (nonatomic, readonly) HCMediaType *mediaType;

@property (nonatomic, readonly) NSDictionary *embeddedSerializers;

@property (nonatomic, readonly) NSDictionary *embeddedResourceActions;

/**
 The character set used when doing request serializations.
 */
@property (nonatomic, readonly) HCCharset *requestSerializationCharacterSet;

/**
 The character set used when doing response deserializations.
 */
@property (nonatomic, readonly) HCCharset *responseSerializationCharacterSet;

@end
