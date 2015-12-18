//
//  HCAFURLRequestSerializer.h
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
#import <AFNetworking/AFURLRequestSerialization.h>

@class HCAuthorization;
@class HCCharset;
@class HCMediaType;
@protocol HCResourceSerializer;

/**
 An implementation of AFNetworking's request serializer that would leverage an
 HC resource serializer.
*/
@interface HCAFURLRequestSerializer : AFHTTPRequestSerializer

#pragma mark - Initializers

/**
 Creates and returns a serializer to be used for requests that contain an entity
 body (i.e., HTTP POST and PUT).
 @param accept the media type to use for the Accept header
 @param acceptCharset the charset to use for the Accept-Charset header
 @param acceptLang the language to use for the Accept-Language header
 @param contentType the media type to use for the Content-Type header
 @param hcserializer the serializer to use to serialize a resource model when
        issuing the HTTP POST or PUT.
 @param timeout The amount of time in seconds to wait for the request to
 @param cachePolicy The cache policy to use for requests.
 @param otherHeaders Additional headers to include in the request.
 complete.
 @return an AFNetworking-compliant request serializer appropriate for HTTP POST
         and PUT requests.
 */
- (id)initWithAccept:(HCMediaType *)accept
       acceptCharset:(HCCharset *)acceptCharset
      acceptLanguage:(NSString *)acceptLang
       authorization:(HCAuthorization *)authorization
        hcserializer:(id<HCResourceSerializer>)hcserializer
             timeout:(NSInteger)timeout
         cachePolicy:(NSURLRequestCachePolicy)cachePolicy
        otherHeaders:(NSDictionary *)otherHeaders;

/**
 Creates and returns a serializer to be used for requests that do not contain
 an entity body (e.g., HTTP GET and HEAD).
 @param accept the media type to use for the Accept header
 @param acceptCharset the charset to use for the Accept-Charset header
 @param acceptLang the language to use for the Accept-Language header
 @param timeout The amount of time in seconds to wait for the request to
 complete.
 @param cachePolicy The cache policy to use for requests.
 @param otherHeaders Additional headers to include in the request.
 @return an AFNetworking-compliant request serializer appropriate for HTTP GET
 HEAD, etc requests.
*/
- (id)initWithAccept:(HCMediaType *)accept
       acceptCharset:(HCCharset *)acceptCharset
      acceptLanguage:(NSString *)acceptLang
       authorization:(HCAuthorization *)authorization
             timeout:(NSInteger)timeout
         cachePolicy:(NSURLRequestCachePolicy)cachePolicy
        otherHeaders:(NSDictionary *)otherHeaders;

@end
