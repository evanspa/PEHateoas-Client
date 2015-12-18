//
//  HCUtils.h
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
 HTTP-date format as defined in RFC 7231.
 */
FOUNDATION_EXPORT NSString * const HTTP_DATE_FORMAT_PATTERN;

/**
 A collection of helper functions.
 */
@interface HCUtils : NSObject

#pragma mark - General

/**
 @return A dictionary that maps character set string (e.g., 'UTF-8') to
 the corresponding numerical constant defined in Cocoa.
 */
+ (NSDictionary *)charsetStringToSysConstant;

+ (BOOL)isSuccessResponse:(NSHTTPURLResponse *)httpResponse;

#pragma mark - URL related

/**
 @return YES If the given string represents an absolute URL; NO otherwise.
 */
+ (BOOL)doesRepresentAbsoluteURL:(NSString *)urlString;

/**
 @param urlString A potentially partial URL representing the URI of some
 resource (it may be a full, absolute URL, or, it may just be a simple name).
 @param resourceUrl A URL that will be used to piece together the full absolute
 URI of the intendend resource if urlString is not already an aboslute URI.
 @returns An absolute URL representing the URI of some resource.  If urlString
 is already an absolute URL, it is returned.  If urlString is not an absolute
 URL, an absolute URL will be formed by merging urlString with resourceUrl.  If
 urlString is not an absolute URL (i.e., it doesn't start with a protocol
 identifier, such as "http://" or "https://"), but DOES start with a
 forward-slash, the absolute URL formed will be the protocol + host name of
 resourceUrl + urlString.  If urlString does NOT start with a forward-slash, the
 absolute URL formed will be resourceUrl + urlString.
 */
+ (NSURL *)ResourceURLFromString:(NSString *)urlString
            enclosingResourceURL:(NSURL *)resourceUrl;

/**
 @return The value of the "Location" header of the HTTP response, if present;
 otherwise returns nil.
 */
+ (NSString *)locationFromResponse:(NSHTTPURLResponse *)httpResponse;

/**
 @return The value of the "Location" header of the HTTP response as a NSURL
 instance, if present; otherwise returns nil.
 */
+ (NSURL *)locationAsUrlFromResponse:(NSHTTPURLResponse *)httpResp;

/**
 @return The value of the "Last-Modified" header of the HTTP response as a
 date, if present; otherwise returns nil.
 */
+ (NSDate *)lastModifiedFromResponse:(NSHTTPURLResponse *)httpResp;

/**
 @return The media type (aka, value of the "Content-Type" header) of the HTTP
 response.  If the response is empty, returns nil.
 */
+ (HCMediaType *)mediaTypeFromResponse:(NSHTTPURLResponse *)httpResp;

/**
 @return The value of the given string as an NSDate, assuming the given string
 is formatted as an HTTP RFC 7231 date.
 */
+ (NSDate *)rfc7231DateFromString:(NSString *)dateString;

/**
 @return A string formatted as an HTTP RFC 7231 date from the given NSDate
 instance.
 */
+ (NSString *)rfc7231StringFromDate:(NSDate *)date;

/**
 Convenience function that parses and returns the relations contained in a local
 JSON file representing some resource (usually a so-called 'starting point'
 resource reprsenting the API site-map of some hypermedia REST service).  The
 relations encapsulated in the JSON file are assumed to be HAL-formatted.
 @param bundle Bundle containing the file.
 @param fileName The name of the file (excluding the extension; the extension is
 already assumed to be ".json").
 @param mediaType The media type of the resource encapsulated by the JSON file.
 @return A dictionary of the relations contained by the resource; the
 non-relations part of the resource (i.e., the model) is ignored.
 */
+ (NSDictionary *)relsFromLocalHalJsonResource:(NSBundle *)bundle
                                      fileName:(NSString *)fileName
                          resourceApiMediaType:(HCMediaType *)mediaType;

@end
