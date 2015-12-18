//
//  HCResource.h
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
@class HCMediaType;

/**
 Abstraction for an HTTP resource.
 */
@interface HCResource : NSObject

#pragma mark - Initializers

/**
 Creates and returns a new instance with the given data elements.
 @param mediaType the internet media type for the resource (it's type)
 @param uri the identifier for the resource
 @param model the underlying model backing the resource
 @return the created resource instance
*/
- (id)initWithMediaType:(HCMediaType *)mediaType
                    uri:(NSURL *)uri
                  model:(id)model;

/**
 Creates and returns a new instance with the given data elements.
 @param mediaType the internet media type for the resource (it's type)
 @param uri the identifier for the resource
 @return the created resource instance
*/
- (id)initWithMediaType:(HCMediaType *)mediaType
                    uri:(NSURL *)uri;

#pragma mark - Conveniences

- (instancetype)copyWithNewUri:(NSURL *)newUri;

/**
 For when a resource instance is needed, but only the URL is needed/relevant.
 */
+ (instancetype)resourceWithUri:(NSURL *)url;

#pragma mark - Equality

/**
 @param resource the resource with which to compare the receiving resource
 @return a Boolean value that indicates whether the receiving resource is
 equal to the given resource.
*/
- (BOOL)isEqualToResource:(HCResource *)resource;

#pragma mark - Properties

/**
 The media type
 */
@property (nonatomic, readonly) HCMediaType *mediaType;

/**
 The identifier
 */
@property (nonatomic, readonly) NSURL *uri;

/**
 The backing model object
 */
@property (nonatomic, readonly) id model;

#pragma mark - Methods

- (HCResource *)ResourceByAppendingQueryString:(NSString *)queryString;

@end
