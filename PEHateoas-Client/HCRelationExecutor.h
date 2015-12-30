//
//  HCRelationExecutor.h
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
#import "HCDefs.h"
@protocol HCResourceSerializer;
@class HCCharset;
@class HCAuthorization;
@class HCAuthentication;
@class HCResource;
@class HCMediaType;

FOUNDATION_EXPORT NSString * const HTTP_DATE_FORMAT;

/**
 An abstraction for executing a link relation by issuing an HTTP GET, POST, PUT,
 DELETE, etc against the URI of the relation's target resource.
 */
@interface HCRelationExecutor : NSObject

#pragma mark - Initializers

/**
 Creates and initializes a new relation executor with the given parameters used
 to populate request headers when requests are made.
 @param acceptMediaType the value to use for the "Accept" header when making
 requests
 @param acceptCharset the value to use for the "Accept-Charset" header when
 making requests
 @param acceptLanguage the value to use for the "Accept-Language" header when
 making requests
 @param contentType the value to use for the "Content-Type" header when making
 requests that contain an entity (i.e., HTTP POST and PUT)
 @param contentTypeCharset the value to use for the "charset" parameter of the
 "Content-Type" header value when making requests that contain an entity (i.e.,
 HTTP POST and PUT)
 @return a new, initialized HCRelationExecutor instance
 */
- (id)initWithDefaultAcceptCharset:(HCCharset *)acceptCharset
             defaultAcceptLanguage:(NSString *)acceptLanguage
         defaultContentTypeCharset:(HCCharset *)contentTypeCharset
          allowInvalidCertificates:(BOOL)allowInvalidCertificates;

#pragma mark - Properties

/** The 'Accept-Charset' to use for HTTP requests. */
@property (nonatomic, readonly) HCCharset *acceptCharset;

/** The 'Accept-Language' to use for HTTP requests. */
@property (nonatomic, readonly) NSString *acceptLanguage;

/** Whether or not invalid SSL certificates should be allowed. */
@property (nonatomic, readonly) BOOL allowInvalidCertificates;

/**
 The charset to use within the 'Content-Type' header for HTTP POST/PUT requests.
 */
@property (nonatomic, readonly) HCCharset *contentTypeCharset;

#pragma mark - Helpers

/**
 Returns a date formatter for the given pattern.
 @param pattern The date pattern.
 @return A date formatter for the given pattern.
 */
+ (NSDateFormatter *)dateFormatterWithPattern:(NSString *)pattern;

/**
 Returns the value of the scheme within an WWW-Authenticate response header.
 @param authHeaderVal The full value of the WWW-Authenticate response header.
 @return The value of the scheme.
*/
+ (NSString *)schemeForAuthHeaderValue:(NSString *)authHeaderVal;

/**
 Returns the value of the realm within an WWW-Authenticate response header.
 @param authHeaderVal The full value of the WWW-Authenticate response header.
 @return The value of the realm.
 */
+ (NSString *)realmForAuthHeaderValue:(NSString *)authHeaderVal;

#pragma mark - Executors

/**
 Issues an HTTP GET request against the given target resource (the target
 resource encapsulates the URI of the GET).  The response body will be
 deserialized using the given targetSerializer object.  Upon success, the
 target serializer will parse the response into 2 logical parts: a resource
 model and a collection of relations (hypermedia links).  That makes this method
 ideal for interacting with a hypermedia-enabled REST API (i.e., a REST API that
 leverages the HATEOAS constraint).  These 2 logical parts, including the raw
 HTTP response, are arguments to the success block.  If a 4XX response is
 received, the client error block will be invoked.  If a 5XX response is
 received, the server error block will be invoked.  If a connection cannot be
 made to the endpoint encoded by the target resource's URI, the connection
 failure block will be invoked.  Temporary and permanent 3XX redirects will be
 followed automatically.
 @param targetResource the resource that is being GET'd (encapsulates the
 URI)
 @param targetSerializer responsible for deserializing the response into a
 resource model and relations colleciton
 @param success block that is executed upon getting a 200; the block receives
 the deserialized response model and relations as arguments (including the raw
 HTTP response object)
 @param completionQueue The queue used to execution the completion blocks on.
 Can be nil (in which case the main queue is used).
 @param clientErr block executed upon receiving a 4XX status code
 @param serverErr block executed upon receiving a 5XX status code
 @param unavailableError Block executed upon receiving a 503 status code along
 with a "retry-after" header.  If a 503 is returned, but there is no
 "retry-after" header, then the serverErrror block will be called.
 @param connFailure block executed in the event there is a failure in attempting
 to connect to the server (encoded in the URI of the target reosurce object)
 @param timeout The amount of time in seconds to wait for the request to
 complete.  If the request does not complete in the provided timeout, then
 the connectionFailure block will be executed.
 */
- (void)doGetForTargetResource:(HCResource *)targetResource
                    parameters:(NSDictionary *)parameters
               ifModifiedSince:(NSDate *)modifiedSince
              targetSerializer:(id<HCResourceSerializer>)targetSerializer
                  asynchronous:(BOOL)asynchronous
               completionQueue:(dispatch_queue_t)completionQueue
                 authorization:(HCAuthorization *)authorization
                       success:(HCGETSuccessBlk)success
                   redirection:(HCRedirectionBlk)redirection
                   clientError:(HCClientErrorBlk)clientErr
        authenticationRequired:(HCAuthReqdErrorBlk)authRequired
                   serverError:(HCServerErrorBlk)serverErr
              unavailableError:(HCServerUnavailableBlk)unavailableErr
             connectionFailure:(HCConnFailureBlk)connFailure
                       timeout:(NSInteger)timeout
                   cachePolicy:(NSURLRequestCachePolicy)cachePolicy
                  otherHeaders:(NSDictionary *)otherHeaders;

- (void)doGetForURLString:(NSString *)URLString
               parameters:(NSDictionary *)parameters
          ifModifiedSince:(NSDate *)modifiedSince
         targetSerializer:(id<HCResourceSerializer>)targetSerializer
             asynchronous:(BOOL)asynchronous
          completionQueue:(dispatch_queue_t)completionQueue
            authorization:(HCAuthorization *)authorization
                  success:(HCGETSuccessBlk)success
              redirection:(HCRedirectionBlk)redirection
              clientError:(HCClientErrorBlk)clientErr
   authenticationRequired:(HCAuthReqdErrorBlk)authRequired
              serverError:(HCServerErrorBlk)serverErr
         unavailableError:(HCServerUnavailableBlk)unavailableErr
        connectionFailure:(HCConnFailureBlk)connFailure
                  timeout:(NSInteger)timeout
              cachePolicy:(NSURLRequestCachePolicy)cachePolicy
             otherHeaders:(NSDictionary *)otherHeaders;

/**
 Issues an HTTP POST request against the given target resource (the target
 resource encapsulates the URI of the POST).  The request body will be
 serialized using the given paramSerializer object.  Upon success, the success
 block will be executed.  The success block receives as one of its parameters
 the URI of the newly-created resource.

 If a 4XX response is received, the client error block will be invoked.  If a
 5XX response is received, the server error block will be invoked.  If a
 connection cannot be made to the endpoint encoded by the target resource's URI,
 the connection failure block will be invoked.  Temporary and permanent 3XX
 redirects will be followed automatically.

 @param targetResource the resource that is being POST'd to (encapsulates the
 URI)
 @param resourceModelParam the resource entity to be POST'd
 @param paramSerializer responsible for serializing the resourceModelParam
 suitable for transmission
 @param responseEntitySerializer Deserializes the response entity, if present,
 into a model object.
 @param completionQueue The queue used to execution the completion blocks on.
 Can be nil (in which case the main queue is used).
 @param success block that is executed upon getting a 20X; the block receives
 the location URI of the newly created source (if a resource was created), a
 deserialized response model (if the response contains an entity) and relations
 as arguments (including the raw HTTP response object).
 @param clientErr block executed upon receiving a 4XX status code
 @param serverErr block executed upon receiving a 5XX status code
 @param unavailableError Block executed upon receiving a 503 status code along
 with a "retry-after" header.  If a 503 is returned, but there is no
 "retry-after" header, then the serverErrror block will be called.
 @param connFailure block executed in the event there is a failure in attempting
 to connect to the server (encoded in the URI of the target reosurce object)
 @param timeout The amount of time in seconds to wait for the request to
 complete.  If the request does not complete in the provided timeout, then
 the connectionFailure block will be executed.
 @param otherHeaders Additional headers to include in the request.
 */
- (void)doPostForTargetResource:(HCResource *)targetResource
             resourceModelParam:(id)resourceModelParam
                paramSerializer:(id<HCResourceSerializer>)paramSerializer
       responseEntitySerializer:(id<HCResourceSerializer>)responseEntitySerializer
                   asynchronous:(BOOL)asynchronous
                completionQueue:(dispatch_queue_t)completionQueue
                  authorization:(HCAuthorization *)authorization
                        success:(HCPOSTSuccessBlk)success
                    redirection:(HCRedirectionBlk)redirection
                    clientError:(HCClientErrorBlk)clientErr
         authenticationRequired:(HCAuthReqdErrorBlk)authRequired
                    serverError:(HCServerErrorBlk)serverErr
               unavailableError:(HCServerUnavailableBlk)unavailableErr
              connectionFailure:(HCConnFailureBlk)connFailure
                        timeout:(NSInteger)timeout
                   otherHeaders:(NSDictionary *)otherHeaders;

/**
 Issues an HTTP PUT request against the given target resource (the target
 resource encapsulates the URI of the PUT).  The request body will be
 serialized using the given target serializer object.  Upon success, the success
 block will be executed.  The success block receives as one of its parameters
 the resource model instance if a 200 is returned.  If a 204 is returned (success,
 but no response content), then the success block's resource model parameter
 will be null.  Usually, 204 should be returned for a successful PUT.  However,
 if the server modifies/augments the resource in anyway as part of processing
 the PUT, and wishes to return it, then it can in the response body and return a
 200 code instead of a 204.

 If a 4XX response is received, the client error block will be invoked.  If a
 5XX response is received, the server error block will be invoked.  If a
 connection cannot be made to the endpoint encoded by the target resource's URI,
 the connection failure block will be invoked.  Temporary and permanent 3XX
 redirects will be followed automatically.

 @param targetResource the resource that is being PUT'd to (encapsulates the
 URI and model)
 @param targetSerializer responsible for serializing the model instance
 associated with the targetResource parameter, suitable for transmission.  Also
 deserializes the response entity, if present, into a model object.  For 204
 responses (no response body), this parameter is rightfully ignored when
 processing the response.
 @param completionQueue The queue used to execution the completion blocks on.
 Can be nil (in which case the main queue is used).
 @param success block that is executed upon getting a 20X
 @param clientErr block executed upon receiving a 4XX status code
 @param serverErr block executed upon receiving a 5XX status code
 @param unavailableError Block executed upon receiving a 503 status code along
 with a "retry-after" header.  If a 503 is returned, but there is no
 "retry-after" header, then the serverErrror block will be called.
 @param connFailure block executed in the event there is a failure in attempting
 to connect to the server (encoded in the URI of the target reosurce object)
 @param timeout The amount of time in seconds to wait for the request to
 complete.  If the request does not complete in the provided timeout, then
 the connectionFailure block will be executed.
 @param otherHeaders Additional headers to include in the request.
 */
- (void)doPutForTargetResource:(HCResource *)targetResource
              targetSerializer:(id<HCResourceSerializer>)targetSerializer
                  asynchronous:(BOOL)asynchronous
               completionQueue:(dispatch_queue_t)completionQueue
                 authorization:(HCAuthorization *)authorization
                       success:(HCPUTSuccessBlk)success
                   redirection:(HCRedirectionBlk)redirection
                   clientError:(HCClientErrorBlk)clientErr
        authenticationRequired:(HCAuthReqdErrorBlk)authRequired
                   serverError:(HCServerErrorBlk)serverErr
              unavailableError:(HCServerUnavailableBlk)unavailableErr
                      conflict:(HCConflictBlk)conflict
             connectionFailure:(HCConnFailureBlk)connFailure
                       timeout:(NSInteger)timeout
                  otherHeaders:(NSDictionary *)otherHeaders;

- (void)doPutForTargetResource:(HCResource *)targetResource
             ifUnmodifiedSince:(NSDate *)unmodifiedSince
              targetSerializer:(id<HCResourceSerializer>)targetSerializer
                  asynchronous:(BOOL)asynchronous
               completionQueue:(dispatch_queue_t)completionQueue
                 authorization:(HCAuthorization *)authorization
                       success:(HCPUTSuccessBlk)success
                   redirection:(HCRedirectionBlk)redirection
                   clientError:(HCClientErrorBlk)clientErr
        authenticationRequired:(HCAuthReqdErrorBlk)authRequired
                   serverError:(HCServerErrorBlk)serverErr
              unavailableError:(HCServerUnavailableBlk)unavailableErr
                      conflict:(HCConflictBlk)conflict
             connectionFailure:(HCConnFailureBlk)connFailure
                       timeout:(NSInteger)timeout
                  otherHeaders:(NSDictionary *)otherHeaders;

- (void)doDeleteOfTargetResource:(HCResource *)targetResource
         wouldBeTargetSerializer:(id<HCResourceSerializer>)wouldBeTargetSerializer
                    asynchronous:(BOOL)asynchronous
                 completionQueue:(dispatch_queue_t)completionQueue
                   authorization:(HCAuthorization *)authorization
                         success:(HCDELETESuccessBlk)success
                     redirection:(HCRedirectionBlk)redirection
                     clientError:(HCClientErrorBlk)clientErr
          authenticationRequired:(HCAuthReqdErrorBlk)authRequired
                     serverError:(HCServerErrorBlk)serverErr
                unavailableError:(HCServerUnavailableBlk)unavailableErr
                        conflict:(HCConflictBlk)conflict
               connectionFailure:(HCConnFailureBlk)connFailure
                         timeout:(NSInteger)timeout
                    otherHeaders:(NSDictionary *)otherHeaders;

- (void)doDeleteOfTargetResource:(HCResource *)targetResource
               ifUnmodifiedSince:(NSDate *)unmodifiedSince
         wouldBeTargetSerializer:(id<HCResourceSerializer>)wouldBeTargetSerializer
                    asynchronous:(BOOL)asynchronous
                 completionQueue:(dispatch_queue_t)completionQueue
                   authorization:(HCAuthorization *)authorization
                         success:(HCDELETESuccessBlk)success
                     redirection:(HCRedirectionBlk)redirection
                     clientError:(HCClientErrorBlk)clientErr
          authenticationRequired:(HCAuthReqdErrorBlk)authRequired
                     serverError:(HCServerErrorBlk)serverErr
                unavailableError:(HCServerUnavailableBlk)unavailableErr
                        conflict:(HCConflictBlk)conflict
               connectionFailure:(HCConnFailureBlk)connFailure
                         timeout:(NSInteger)timeout
                    otherHeaders:(NSDictionary *)otherHeaders;

@end
