//
//  HCRelationExecutorTests.m
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

#import "HCRelationExecutor.h"
#import "HCHalJsonSerializer.h"
#import <PEWire-Control/PEHttpResponseSimulator.h>
#import "HCTestUtils.h"
#import <CocoaLumberjack/DDLog.h>
#import <CocoaLumberjack/DDTTYLogger.h>
#import <CocoaLumberjack/DDASLLogger.h>
#import "HCCharset.h"
#import "HCResource.h"
#import "HCAuthentication.h"
#import "HCMediaType.h"
#import <Kiwi/Kiwi.h>

SPEC_BEGIN(HCRelationExecutorSpec)

describe(@"HCRelationExecutor", ^{

    __block HCRelationExecutor *relExecutor;
    __block HCMediaType *mediaType;
    __block NSURL *baseUrl;
    __block HCHalJsonSerializer *jsonSerializer;
    __block BOOL isSuccess;
    __block BOOL isRedirectionClass;
    __block BOOL isConflict;
    __block BOOL isClientError;
    __block BOOL isAuthRequired;
    __block BOOL isServerError;
    __block BOOL isServerUnavailableWithRetry;
    __block BOOL isConnFailure;

    void (^(^newEmptyGetSuccessBlk)(void))(NSURL *, id, NSDate *, NSDictionary *, NSHTTPURLResponse *) = ^{
      return (^(NSURL *location, id resModel, NSDate *lastModified, NSDictionary *rels, NSHTTPURLResponse *resp) {
          isSuccess = YES;
        });
      };

    void (^(^newRedirectBlk)(NSURL *, BOOL, BOOL))(NSURL *, BOOL, BOOL, NSHTTPURLResponse *) =
      ^(NSURL *expectedLocation, BOOL expectedMovedPermanently, BOOL expectedNotModified) {
        return (^(NSURL *location, BOOL movedPermanently, BOOL notModified, NSHTTPURLResponse *resp) {
          isRedirectionClass = YES;
          [[theValue(movedPermanently) should] equal:theValue(expectedMovedPermanently)];
          [[theValue(notModified) should] equal:theValue(expectedNotModified)];
          if (movedPermanently) {
            [location shouldNotBeNil];
             NSURL *expectedLocationForCompare = [NSURL URLWithString:[expectedLocation absoluteString]];
            [[location should] equal:expectedLocationForCompare];
          }
        });
      };

    void (^(^newClientErrorBlk)(NSInteger))(NSHTTPURLResponse *) =
      ^(NSInteger expectedStatusCode) {
      return (^(NSHTTPURLResponse *httpResp) {
          isClientError = YES;
          [[theValue([httpResp statusCode]) should]
              equal:theValue(expectedStatusCode)];
        });
      };
    void (^(^newAuthReqdBlk)(NSString *,
                             NSString *,
                             NSDictionary *))(HCAuthentication *,
                                              NSHTTPURLResponse *) =
      ^(NSString *expectedScheme,
        NSString *expectedRealm,
        NSDictionary *expectedAuthParams) {
      return (^(HCAuthentication *auth, NSHTTPURLResponse *resp) {
          isAuthRequired = YES;
          if (expectedScheme) {
            [[auth should] equal:[[HCAuthentication alloc]
                                  initWithAuthScheme:expectedScheme
                                               realm:expectedRealm
                                          authParams:expectedAuthParams]];
          } else {
            [auth shouldBeNil];
          }
        });
    };
    void (^(^newServerErrorBlk)(NSInteger))(NSHTTPURLResponse *) =
      ^(NSInteger expectedStatusCode) {
        return (^(NSHTTPURLResponse *httpResp) {
            isServerError = YES;
            [[theValue([httpResp statusCode]) should]
              equal:theValue(expectedStatusCode)];
          });
    };
    void (^(^newServerUnavailableBlk)(NSDate *, NSNumber *))(NSDate *, NSHTTPURLResponse *) =
      ^(NSDate *expectedRetryAfter, NSNumber *expectedRangeFromNow){
        return (^(NSDate *retryAfter, NSHTTPURLResponse *resp) {
            isServerUnavailableWithRetry = YES;
            [[theValue([resp statusCode]) should] equal:theValue(503)];
            [retryAfter shouldNotBeNil];
            if (expectedRetryAfter) {
              [[retryAfter should] equal:expectedRetryAfter];
            } else {
              NSDate *lowerBound = [[NSDate date] dateByAddingTimeInterval:-5];
              NSDate *upperBound =
              [[NSDate date]
                  dateByAddingTimeInterval:([expectedRangeFromNow intValue] + 5)];
              [[retryAfter should] beInTheIntervalFrom:lowerBound to:upperBound];
            }
          });
    };
    void (^(^newConnFailureBlk)(NSInteger))(NSInteger) =
      ^(NSInteger expectedErrorCode) {
        return (^(NSInteger nsurlerrType) {
            isConnFailure = YES;
            [[theValue(nsurlerrType) should] equal:theValue(expectedErrorCode)];
          });
    };
    __block void (^expectedFutureFlags)(BOOL, BOOL, BOOL, BOOL, BOOL, BOOL, BOOL, BOOL, NSInteger) =
      ^(BOOL expectedSuccessFlag,
        BOOL expectedRedirectionClassFlag,
        BOOL expectedConflictFlag,
        BOOL expectedClientErrorFlag,
        BOOL expectedAuthReqdFlag,
        BOOL expectedServerErrorFlag,
        BOOL expectedServerUnavailableFlag,
        BOOL expectedConnFailureFlag,
        NSInteger awaitFor) {
      [[expectFutureValue(theValue(isSuccess))
          shouldEventuallyBeforeTimingOutAfter(awaitFor)]
            equal:theValue(expectedSuccessFlag)];
      [[expectFutureValue(theValue(isRedirectionClass)) shouldEventuallyBeforeTimingOutAfter(awaitFor)]
         equal:theValue(expectedRedirectionClassFlag)];
      [[expectFutureValue(theValue(isConflict)) shouldEventuallyBeforeTimingOutAfter(awaitFor)]
          equal:theValue(expectedConflictFlag)];
      [[expectFutureValue(theValue(isClientError)) shouldEventuallyBeforeTimingOutAfter(awaitFor)]
          equal:theValue(expectedClientErrorFlag)];
      [[expectFutureValue(theValue(isAuthRequired)) shouldEventuallyBeforeTimingOutAfter(awaitFor)]
          equal:theValue(expectedAuthReqdFlag)];
      [[expectFutureValue(theValue(isServerError)) shouldEventuallyBeforeTimingOutAfter(awaitFor)]
          equal:theValue(expectedServerErrorFlag)];
      [[expectFutureValue(theValue(isServerUnavailableWithRetry)) shouldEventuallyBeforeTimingOutAfter(awaitFor)]
          equal:theValue(expectedServerUnavailableFlag)];
      [[expectFutureValue(theValue(isConnFailure)) shouldEventuallyBeforeTimingOutAfter(awaitFor)]
          equal:theValue(expectedConnFailureFlag)];
    };

    beforeAll(^{
        [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        mediaType = [HCMediaType MediaTypeFromString:@"application/json"];
        baseUrl = [NSURL URLWithString:@"http://www.example.com"];
        jsonSerializer =
          [[HCHalJsonSerializer alloc]
           initWithMediaType:mediaType charset:[HCCharset UTF8] serializersForEmbeddedResources:@{} actionsForEmbeddedResources:@{}];
        relExecutor =
          [[HCRelationExecutor alloc]
            initWithDefaultAcceptCharset:[HCCharset UTF8]
                   defaultAcceptLanguage:@"en-US"
               defaultContentTypeCharset:[HCCharset UTF8]
                allowInvalidCertificates:NO];
      });

    beforeEach(^{
        [PEHttpResponseSimulator clearSimulations];
        isSuccess = NO;
        isRedirectionClass = NO;
        isConflict = NO;
        isClientError = NO;
        isAuthRequired = NO;
        isServerError = NO;
        isServerUnavailableWithRetry = NO;
        isConnFailure = NO;
      });

    NSURL *(^url)(NSString *) = ^ NSURL * (NSString *path) {
      return [[NSURL alloc]initWithString:path relativeToURL:baseUrl];
    };

    NSString *(^contentsOfMockResponse)(NSString *) =
      ^ NSString * (NSString *xmlFileName) {
      NSStringEncoding enc;
      NSError *err;
      NSString *path =
      [[NSBundle bundleForClass:[self class]]
        pathForResource:xmlFileName
                 ofType:@"xml"
            inDirectory:@"http-mock-responses"];
      return [NSString stringWithContentsOfFile:path
                                   usedEncoding:&enc
                                          error:&err];
    };

    void (^resourceModelTester)(NSDictionary *,
                                NSDictionary *) = ^ (NSDictionary *expectedResModel,
                                                     NSDictionary *actualResModel) {
      if (expectedResModel) {
        [actualResModel shouldNotBeNil];
        [[theValue([actualResModel isEqualToDictionary:expectedResModel])
                  should] beYes];
        [[actualResModel objectForKey:@"_links"] shouldBeNil];
      } else {
        [actualResModel shouldBeNil];
      }
    };

    void (^successExpectationsForGet)(NSString *,
                                      NSString *,
                                      NSDictionary *,
                                      NSArray *) = ^(NSString *path,
                                                     NSString *xmlHttpRespFile,
                                                     NSDictionary *expectedResModel,
                                                     NSArray *expectedRelations) {
      HCResource *targetRes =
              [[HCResource alloc] initWithMediaType:mediaType uri:url(path)];
      HCGETSuccessBlk successBlk = ^(NSURL *location,
                                     id resourceModel,
                                     NSDate *lastModified,
                                     NSDictionary *relations,
                                     NSHTTPURLResponse *resp) {
        isSuccess = YES;
        [resp shouldNotBeNil];
        [[theValue([resp statusCode]) should] equal:theValue(200)];
        [[theValue([[resp allHeaderFields] count]) should] equal:theValue(6)];
        resourceModelTester(expectedResModel, resourceModel);
        [HCTestUtils relations:relations
          shouldEqualRelations:expectedRelations];
      };
      [PEHttpResponseSimulator
        simulateResponseFromXml:contentsOfMockResponse(xmlHttpRespFile)
          pathsRelativeToBundle:[NSBundle bundleForClass:[self class]]
                 requestLatency:0
                responseLatency:0];
      [relExecutor doGetForTargetResource:targetRes
                               parameters:nil
                          ifModifiedSince:nil
                         targetSerializer:jsonSerializer
                             asynchronous:YES
                          completionQueue:nil
                            authorization:nil
                                  success:successBlk
                              redirection:newRedirectBlk(nil, NO, NO)
                              clientError:newClientErrorBlk(-1)
                   authenticationRequired:nil
                              serverError:newServerErrorBlk(-1)
                         unavailableError:newServerUnavailableBlk(nil, nil)
                        connectionFailure:newConnFailureBlk(-1)
                                  timeout:60
                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                             otherHeaders:nil];
      expectedFutureFlags(YES, NO, NO, NO, NO, NO, NO, NO, 60);
    };

    void (^successExpectationsForPut)(NSString *,
                                      NSString *,
                                      NSDictionary *,
                                      NSDictionary *,
                                      NSArray *,
                                      NSInteger) = ^(NSString *path,
                                                     NSString *xmlHttpRespFile,
                                                     NSDictionary *targetResModel,
                                                     NSDictionary *expectedResModel,
                                                     NSArray *expectedRelations,
                                                     NSInteger expectedRespCode) {
      HCResource *targetRes =
      [[HCResource alloc] initWithMediaType:mediaType uri:url(path) model:targetResModel];
      HCPUTSuccessBlk successBlk = ^(NSURL *location,
                                     id resourceModel,
                                     NSDate *lastModified,
                                     NSDictionary *relations,
                                     NSHTTPURLResponse *resp) {
        isSuccess = YES;
        [resp shouldNotBeNil];
        [[theValue([resp statusCode]) should] equal:theValue(expectedRespCode)];
        [[theValue([[resp allHeaderFields] count]) should] equal:theValue(6)];
        if ([resp statusCode] == 200 && resourceModel) {
          resourceModelTester(expectedResModel, resourceModel);
          [HCTestUtils relations:relations shouldEqualRelations:expectedRelations];
        }
      };
      HCConflictBlk conflictBlk = ^(NSURL *location,
                                    id resourceModel,
                                    NSDate *lastModified,
                                    NSDictionary *relations,
                                    NSHTTPURLResponse *resp) {
        isConflict = YES;
        [resp shouldNotBeNil];
        [[theValue([resp statusCode]) should] equal:theValue(expectedRespCode)];
        resourceModelTester(expectedResModel, resourceModel);
        [HCTestUtils relations:relations shouldEqualRelations:expectedRelations];
      };
      [PEHttpResponseSimulator
        simulateResponseFromXml:contentsOfMockResponse(xmlHttpRespFile)
          pathsRelativeToBundle:[NSBundle bundleForClass:[self class]]
                 requestLatency:0
                responseLatency:0];
      [relExecutor doPutForTargetResource:targetRes
                         targetSerializer:jsonSerializer
                             asynchronous:YES
                          completionQueue:nil
                            authorization:nil
                                  success:successBlk
                              redirection:newRedirectBlk(nil, NO, NO)
                              clientError:newClientErrorBlk(-1)
                   authenticationRequired:nil
                              serverError:newServerErrorBlk(-1)
                         unavailableError:newServerUnavailableBlk(nil, nil)
                                 conflict:conflictBlk
                        connectionFailure:newConnFailureBlk(-1)
                                  timeout:60
                             otherHeaders:nil];
      expectedFutureFlags(YES, NO, NO, NO, NO, NO, NO, NO, 60);
    };
  
  void (^conflictExpectationsForPut)(NSString *,
                                    NSString *,
                                    NSDictionary *,
                                    NSDictionary *,
                                    NSArray *,
                                    NSInteger) = ^(NSString *path,
                                                   NSString *xmlHttpRespFile,
                                                   NSDictionary *targetResModel,
                                                   NSDictionary *expectedResModel,
                                                   NSArray *expectedRelations,
                                                   NSInteger expectedRespCode) {
    HCResource *targetRes =
    [[HCResource alloc] initWithMediaType:mediaType uri:url(path) model:targetResModel];
    HCPUTSuccessBlk successBlk = ^(NSURL *location,
                                   id resourceModel,
                                   NSDate *lastModified,
                                   NSDictionary *relations,
                                   NSHTTPURLResponse *resp) {
      isSuccess = YES;
      [resp shouldNotBeNil];
      [[theValue([resp statusCode]) should] equal:theValue(expectedRespCode)];
      [[theValue([[resp allHeaderFields] count]) should] equal:theValue(6)];
      if ([resp statusCode] == 200 && resourceModel) {
        resourceModelTester(expectedResModel, resourceModel);
        [HCTestUtils relations:relations shouldEqualRelations:expectedRelations];
      }
    };
    HCConflictBlk conflictBlk = ^(NSURL *location,
                                  id resourceModel,
                                  NSDate *lastModified,
                                  NSDictionary *relations,
                                  NSHTTPURLResponse *resp) {
      isConflict = YES;
      [resp shouldNotBeNil];
      [[theValue([resp statusCode]) should] equal:theValue(expectedRespCode)];
      resourceModelTester(expectedResModel, resourceModel);
      [HCTestUtils relations:relations shouldEqualRelations:expectedRelations];
    };
    [PEHttpResponseSimulator
     simulateResponseFromXml:contentsOfMockResponse(xmlHttpRespFile)
     pathsRelativeToBundle:[NSBundle bundleForClass:[self class]]
     requestLatency:0
     responseLatency:0];
    [relExecutor doPutForTargetResource:targetRes
                       targetSerializer:jsonSerializer
                           asynchronous:YES
                        completionQueue:nil
                          authorization:nil
                                success:successBlk
                            redirection:newRedirectBlk(nil, NO, NO)
                            clientError:newClientErrorBlk(-1)
                 authenticationRequired:nil
                            serverError:newServerErrorBlk(-1)
                       unavailableError:newServerUnavailableBlk(nil, nil)
                               conflict:conflictBlk
                      connectionFailure:newConnFailureBlk(-1)
                                timeout:60
                           otherHeaders:nil];
    expectedFutureFlags(NO, NO, YES, NO, NO, NO, NO, NO, 60);
  };

    void (^successExpectationsForDelete)(NSString *,
                                         NSString *,
                                         NSInteger) = ^(NSString *path,
                                                        NSString *xmlHttpRespFile,
                                                        NSInteger expectedRespCode) {
      HCResource *targetRes =
        [[HCResource alloc] initWithMediaType:mediaType uri:url(path)];
      HCDELETESuccessBlk successBlk = ^(NSHTTPURLResponse *resp) {
        isSuccess = YES;
        [resp shouldNotBeNil];
        [[theValue([resp statusCode]) should] equal:theValue(expectedRespCode)];
        [[theValue([[resp allHeaderFields] count]) should] equal:theValue(6)];
      };
      HCConflictBlk conflictBlk = ^(NSURL *location,
                                    id resourceModel,
                                    NSDate *lastModified,
                                    NSDictionary *relations,
                                    NSHTTPURLResponse *resp) {
        isConflict = YES;
        [resp shouldNotBeNil];
        [[theValue([resp statusCode]) should] equal:theValue(expectedRespCode)];
      };
      [PEHttpResponseSimulator
        simulateResponseFromXml:contentsOfMockResponse(xmlHttpRespFile)
          pathsRelativeToBundle:[NSBundle bundleForClass:[self class]]
                 requestLatency:0
                responseLatency:0];
      [relExecutor doDeleteOfTargetResource:targetRes
                    wouldBeTargetSerializer:jsonSerializer
                               asynchronous:YES
                            completionQueue:nil
                              authorization:nil
                                    success:successBlk
                                redirection:newRedirectBlk(nil, NO, NO)
                                clientError:newClientErrorBlk(-1)
                     authenticationRequired:nil
                                serverError:newServerErrorBlk(-1)
                           unavailableError:newServerUnavailableBlk(nil, nil)
                                   conflict:conflictBlk
                          connectionFailure:newConnFailureBlk(-1)
                                    timeout:60
                               otherHeaders:nil];
      expectedFutureFlags(YES, NO, NO, NO, NO, NO, NO, NO, 60);
    };

    context(@"2XX responses", ^{
        it(@"GET works properly with normal response", ^{
            NSDictionary *expectedResModel = @{@"last_name" : @"Smith",
                                               @"first_name" : @"John",
                                               @"email" : @"jsmith@ex.com"};
            NSArray *expectedRels = @[
              [HCTestUtils relationWithName:@"self"
                   subjectResourceMediaType:@"application/json"
                         subjectResourceUri:@"http://www.example.com/users/u10391"
                    targetResourceMediaType:@"application/json"
                          targetResourceUri:@"http://www.example.com/users/u10391"],
              [HCTestUtils relationWithName:@"http://update-user"
                   subjectResourceMediaType:@"application/json"
                         subjectResourceUri:@"http://www.example.com/users/u10391"
                    targetResourceMediaType:@"application/xml"
                          targetResourceUri:@"http://www.example.com/users/u10391"]];
            successExpectationsForGet(@"/users/u10391",
                                      @"http-response.200",
                                      expectedResModel,
                                      expectedRels);
          });

        it(@"DELETE works properly with normal 204 response", ^{
            successExpectationsForDelete(@"/users/u10391", @"http-response.delete.204", 204);
          });

        it(@"PUT works properly with normal 204 response", ^{
            NSDictionary *targetResModel = @{@"last_name" : @"Smith",
                                             @"first_name" : @"John",
                                             @"email" : @"jsmith@ex.com"};
            successExpectationsForPut(@"/users/u10391",
                                      @"http-response.put.204", targetResModel,
                                      nil, nil, 204);
          });

        it(@"PUT works properly with normal 200 response", ^{
            NSDictionary *targetResModel = @{@"last_name" : @"Smith",
                                             @"first_name" : @"John",
                                             @"email" : @"jsmith@ex.com"};
            NSDictionary *expectedResModel = @{@"last_name" : @"Smith",
                                               @"first_name" : @"John",
                                               @"email" : @"jsmith@ex.com",
                                               @"salutation" : @"Mr."};
            NSArray *expectedRels = @[
                                      [HCTestUtils relationWithName:@"self"
                                           subjectResourceMediaType:@"application/json"
                                                 subjectResourceUri:@"http://www.example.com/users/u10391"
                                            targetResourceMediaType:@"application/json"
                                                  targetResourceUri:@"http://www.example.com/users/u10391"],
                                         [HCTestUtils relationWithName:@"http://update-user"
                                              subjectResourceMediaType:@"application/json"
                                                    subjectResourceUri:@"http://www.example.com/users/u10391"
                                               targetResourceMediaType:@"application/xml"
                                                     targetResourceUri:@"http://www.example.com/users/u10391"]];
            successExpectationsForPut(@"/users/u10391",
                                      @"http-response.put.200",
                                      targetResModel,
                                      expectedResModel,
                                      expectedRels,
                                      200);
          });
      
      it(@"PUT works properly with a 409 response", ^{
        NSDictionary *targetResModel = @{@"last_name" : @"Smith",
                                         @"first_name" : @"John",
                                         @"email" : @"jsmith@ex.com"};
        NSDictionary *expectedResModel = @{@"last_name" : @"Smith",
                                           @"first_name" : @"John",
                                           @"email" : @"jsmith@ex.com",
                                           @"salutation" : @"Mr."};
        NSArray *expectedRels = @[
                                  [HCTestUtils relationWithName:@"self"
                                       subjectResourceMediaType:@"application/json"
                                             subjectResourceUri:@"http://www.example.com/users/u10391"
                                        targetResourceMediaType:@"application/json"
                                              targetResourceUri:@"http://www.example.com/users/u10391"],
                                  [HCTestUtils relationWithName:@"http://update-user"
                                       subjectResourceMediaType:@"application/json"
                                             subjectResourceUri:@"http://www.example.com/users/u10391"
                                        targetResourceMediaType:@"application/xml"
                                              targetResourceUri:@"http://www.example.com/users/u10391"]];
        conflictExpectationsForPut(@"/users/u10391",
                                   @"http-response.put.409",
                                   targetResModel,
                                   expectedResModel,
                                   expectedRels,
                                   409);
      });

        it(@"POST works properly with 201 response w/no response body", ^{
            NSString *path = @"/users";
            [PEHttpResponseSimulator
              simulateResponseFromXml:contentsOfMockResponse(@"http-response.201")
                pathsRelativeToBundle:[NSBundle bundleForClass:[self class]]
                       requestLatency:0
                      responseLatency:0];
            NSDictionary *resModel = @{@"last_name" : @"Smith",
                                       @"first_name" : @"John",
                                       @"email" : @"jsmith@ex.com"};
            NSURL *expectedLoc =
              [NSURL URLWithString:@"http://www.example.com/users/u70239"];
            HCPOSTSuccessBlk successBlk = ^(NSURL *location,
                                            id resourceModel,
                                            NSDate *lastModified,
                                            NSDictionary *relations,
                                            NSHTTPURLResponse *resp) {
              isSuccess = YES;
              [location shouldNotBeNil];
              [[[location absoluteString] should]
                                   equal:[expectedLoc absoluteString]];
              [resourceModel shouldBeNil];
              [relations shouldBeNil];
            };
            [relExecutor
              doPostForTargetResource:[[HCResource alloc]
                                       initWithMediaType:mediaType uri:url(path)]
                   resourceModelParam:resModel
                      paramSerializer:jsonSerializer
             responseEntitySerializer:jsonSerializer
                         asynchronous:YES
                      completionQueue:nil
                        authorization:nil
                              success:successBlk
                          redirection:newRedirectBlk(nil, NO, NO)
                          clientError:newClientErrorBlk(-1)
               authenticationRequired:nil
                          serverError:newServerErrorBlk(-1)
                     unavailableError:newServerUnavailableBlk(nil, nil)
                    connectionFailure:newConnFailureBlk(-1)
                              timeout:60
                         otherHeaders:nil];
            expectedFutureFlags(YES, NO, NO, NO, NO, NO, NO, NO, 60);
          });

        it(@"POST works properly with 201 response with response body", ^{
            NSString *path = @"/auth-tokens";
            [PEHttpResponseSimulator
              simulateResponseFromXml:contentsOfMockResponse(@"http-response.201.1")
                pathsRelativeToBundle:[NSBundle bundleForClass:[self class]]
                       requestLatency:0
                      responseLatency:0];
            NSDictionary *resModel = @{@"email": @"jsmith@ex.com",
                                       @"password": @"in53cur3"};
            NSURL *expectedLoc =
             [NSURL URLWithString:@"http://www.example.com/auth-tokens/109234810939201002929"];
            HCPOSTSuccessBlk successBlk =
              ^(NSURL *location, id resModel, NSDate *lastModified, NSDictionary *rels, NSHTTPURLResponse *resp) {
              isSuccess = YES;
              [location shouldNotBeNil];
              [[[location absoluteString] should] equal:[expectedLoc absoluteString]];
              [resModel shouldNotBeNil];
              [rels shouldNotBeNil];
              [[rels should] haveCountOf:1];
              [lastModified shouldNotBeNil];
              [[lastModified should]
                equal:[[HCRelationExecutor dateFormatterWithPattern:HTTP_DATE_FORMAT]
                                                     dateFromString:@"Tue, 15 Nov 1994 12:45:26 GMT"]];
              [HCTestUtils relations:rels
                shouldEqualRelations:
                  @[[HCTestUtils relationWithName:@"self"
                         subjectResourceMediaType:@"application/json"
                               subjectResourceUri:@"http://www.example.com/auth-tokens/109234810939201002929"
                          targetResourceMediaType:@"application/json"
                                targetResourceUri:@"http://www.example.com/auth-tokens/109234810939201002929"]]];
            };
            [relExecutor
              doPostForTargetResource:[[HCResource alloc] initWithMediaType:mediaType uri:url(path)]
                   resourceModelParam:resModel
                      paramSerializer:jsonSerializer
             responseEntitySerializer:jsonSerializer
                         asynchronous:YES
                      completionQueue:nil
                        authorization:nil
                              success:successBlk
                          redirection:newRedirectBlk(nil, NO, NO)
                          clientError:newClientErrorBlk(-1)
               authenticationRequired:nil
                          serverError:newServerErrorBlk(-1)
                     unavailableError:newServerUnavailableBlk(nil, nil)
                    connectionFailure:newConnFailureBlk(-1)
                              timeout:60
                        otherHeaders:nil];
            expectedFutureFlags(YES, NO, NO, NO, NO, NO, NO, NO, 60);
          });
      });

    context(@"4XX responses", ^{
        it(@"GET works when receiving a 404 not-found response", ^{
            NSString *path = @"/users/xxx9201";
          [PEHttpResponseSimulator simulateResponseFromXml:contentsOfMockResponse(@"http-response.404")
                                     pathsRelativeToBundle:[NSBundle bundleForClass:[self class]]
                                            requestLatency:0
                                           responseLatency:0];
          [relExecutor doGetForTargetResource:[[HCResource alloc] initWithMediaType:mediaType uri:url(path)]
                                   parameters:nil
                              ifModifiedSince:nil
                             targetSerializer:jsonSerializer
                                 asynchronous:YES
                              completionQueue:nil
                                authorization:nil
                                      success:newEmptyGetSuccessBlk()
                                  redirection:newRedirectBlk(nil, NO, NO)
                                  clientError:newClientErrorBlk(404)
                       authenticationRequired:nil
                                  serverError:newServerErrorBlk(-1)
                             unavailableError:newServerUnavailableBlk(nil, nil)
                            connectionFailure:newConnFailureBlk(-1)
                                      timeout:60
                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                 otherHeaders:nil];
            expectedFutureFlags(NO, NO, NO, YES, NO, NO, NO, NO, 60);
          });

        it(@"401 response works", ^{
            NSString *path = @"/users/xxx9201";
          [PEHttpResponseSimulator simulateResponseFromXml:contentsOfMockResponse(@"http-response.401")
                                     pathsRelativeToBundle:[NSBundle bundleForClass:[self class]]
                                            requestLatency:0
                                           responseLatency:0];
          [relExecutor doGetForTargetResource:[[HCResource alloc] initWithMediaType:mediaType uri:url(path)]
                                   parameters:nil
                              ifModifiedSince:nil
                             targetSerializer:jsonSerializer
                                 asynchronous:YES
                              completionQueue:nil
                                authorization:nil
                                      success:nil
                                  redirection:newRedirectBlk(nil, NO, NO)
                                  clientError:newClientErrorBlk(404)
                       authenticationRequired:newAuthReqdBlk(@"FPAuthToken", @"all", nil)
                                  serverError:newServerErrorBlk(-1)
                             unavailableError:newServerUnavailableBlk(nil, nil)
                            connectionFailure:newConnFailureBlk(-1)
                                      timeout:60
                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                 otherHeaders:nil];
            expectedFutureFlags(NO, NO, NO, NO, YES, NO, NO, NO, 60);
          });

      it(@"401 w/no www-authenticate header response works", ^{
        NSString *path = @"/users/xxx9201";
        [PEHttpResponseSimulator simulateResponseFromXml:contentsOfMockResponse(@"http-response.401.2")
                                   pathsRelativeToBundle:[NSBundle bundleForClass:[self class]]
                                          requestLatency:0
                                         responseLatency:0];
        [relExecutor doGetForTargetResource:[[HCResource alloc] initWithMediaType:mediaType uri:url(path)]
                                 parameters:nil
                            ifModifiedSince:nil
                           targetSerializer:jsonSerializer
                               asynchronous:YES
                            completionQueue:nil
                              authorization:nil
                                    success:nil
                                redirection:newRedirectBlk(nil, NO, NO)
                                clientError:newClientErrorBlk(404)
                     authenticationRequired:newAuthReqdBlk(nil, nil, nil)
                                serverError:newServerErrorBlk(-1)
                           unavailableError:newServerUnavailableBlk(nil, nil)
                          connectionFailure:newConnFailureBlk(-1)
                                    timeout:60
                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                               otherHeaders:nil];
        expectedFutureFlags(NO, NO, NO, NO, YES, NO, NO, NO, 60);
        });
      });

    context(@"Redirection (3XX) responses", ^{
        it(@"GET works when receiving 301 response", ^{
            NSString *path = @"/users/old/u10391";
            [PEHttpResponseSimulator
              simulateResponseFromXml:contentsOfMockResponse(@"http-response.301")
                pathsRelativeToBundle:[NSBundle bundleForClass:[self class]]
                       requestLatency:0
                      responseLatency:0];
            // afnetworking will automatically follow the redirect, so we need
            // to make sure we've simulated the redirect's target resource
          [PEHttpResponseSimulator simulateResponseFromXml:contentsOfMockResponse(@"http-response.200")
                                     pathsRelativeToBundle:[NSBundle bundleForClass:[self class]]
                                            requestLatency:0
                                           responseLatency:0];
          [relExecutor doGetForTargetResource:[[HCResource alloc] initWithMediaType:mediaType uri:url(path)]
                                   parameters:nil
                              ifModifiedSince:nil
                             targetSerializer:jsonSerializer
                                 asynchronous:YES
                              completionQueue:nil
                                authorization:nil
                                      success:newEmptyGetSuccessBlk()
                                  redirection:newRedirectBlk(url(@"/users/u10391"), YES, NO)
                                  clientError:newClientErrorBlk(-1)
                       authenticationRequired:nil
                                  serverError:newServerErrorBlk(-1)
                             unavailableError:newServerUnavailableBlk(nil, nil)
                            connectionFailure:newConnFailureBlk(-1)
                                      timeout:60
                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                 otherHeaders:nil];
            /*
             * So this requires some explaining.  301s are special because
             * although it's a redirect, because it's a PERMANENT redirect, we'd
             * like to know about the resource's new location.  Well, AFNetworking
             * is trying to be nice and automatically follows the redirect, and
             * so, we've added a hook to all "do***" methods of HCRelationExecutor
             * such that if a 301 is encountered, we'll capture it before
             * AFNetworking re-submits the new request, and invoke the provided
             * redirection block.  Now, again, since AFNetworking automatically
             * follows the new URL, the sucess block will ALSO be executed; this
             * is why we pass YES for the first 2 parameters to
             * expectedFutureFlags block.
             */
            expectedFutureFlags(YES, YES, NO, NO, NO, NO, NO, NO, 60);
          });

        it(@"GET works when receiving 304 response", ^{
            NSString *path = @"/users/u10391";
          [PEHttpResponseSimulator simulateResponseFromXml:contentsOfMockResponse(@"http-response.304")
                                     pathsRelativeToBundle:[NSBundle bundleForClass:[self class]]
                                            requestLatency:0
                                           responseLatency:0];
          [relExecutor doGetForTargetResource:[[HCResource alloc] initWithMediaType:mediaType uri:url(path)]
                                   parameters:nil
                              ifModifiedSince:nil
                             targetSerializer:jsonSerializer
                                 asynchronous:YES
                              completionQueue:nil
                                authorization:nil
                                      success:newEmptyGetSuccessBlk()
                                  redirection:newRedirectBlk(nil, NO, YES)
                                  clientError:newClientErrorBlk(-1)
                       authenticationRequired:nil
                                  serverError:newServerErrorBlk(-1)
                             unavailableError:newServerUnavailableBlk(nil, nil)
                            connectionFailure:newConnFailureBlk(-1)
                                      timeout:60
                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                 otherHeaders:nil];
            expectedFutureFlags(NO, YES, NO, NO, NO, NO, NO, NO, 60);
          });

      it(@"GET works properly with 303 redirect response", ^{
          NSString *path = @"/users/tmp/tmp9201";
          [PEHttpResponseSimulator
            simulateResponseFromXml:contentsOfMockResponse(@"http-response.303")
              pathsRelativeToBundle:[NSBundle bundleForClass:[self class]]
                     requestLatency:0
                    responseLatency:0];
          // afnetworking will automatically follow the redirect, so we need
          // to make sure we've simulated the redirect's target resource
        [PEHttpResponseSimulator simulateResponseFromXml:contentsOfMockResponse(@"http-response.200")
                                   pathsRelativeToBundle:[NSBundle bundleForClass:[self class]]
                                          requestLatency:0
                                         responseLatency:0];
        [relExecutor doGetForTargetResource:[[HCResource alloc] initWithMediaType:mediaType uri:url(path)]
                                 parameters:nil
                            ifModifiedSince:nil
                           targetSerializer:jsonSerializer
                               asynchronous:YES
                            completionQueue:nil
                              authorization:nil
                                    success:newEmptyGetSuccessBlk()
                                redirection:newRedirectBlk(nil, NO, NO)
                                clientError:newClientErrorBlk(-1)
                     authenticationRequired:nil
                                serverError:newServerErrorBlk(-1)
                           unavailableError:newServerUnavailableBlk(nil, nil)
                          connectionFailure:newConnFailureBlk(-1)
                                    timeout:60
                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                               otherHeaders:nil];
        expectedFutureFlags(YES, NO, NO, NO, NO, NO, NO, NO, 60);
        });
      });

    context(@"Server Unavailable (503", ^{
        it(@"Works in the event of a 503 with an integer for the retry-after.", ^{
            NSString *path = @"/users/u10391";
          [PEHttpResponseSimulator simulateResponseFromXml:contentsOfMockResponse(@"http-response.503.0")
                                     pathsRelativeToBundle:[NSBundle bundleForClass:[self class]]
                                            requestLatency:0
                                           responseLatency:0];
          [relExecutor doGetForTargetResource:[[HCResource alloc] initWithMediaType:mediaType uri:url(path)]
                                   parameters:nil
                              ifModifiedSince:nil
                             targetSerializer:jsonSerializer
                                 asynchronous:YES
                              completionQueue:nil
                                authorization:nil
                                      success:newEmptyGetSuccessBlk()
                                  redirection:newRedirectBlk(nil, NO, NO)
                                  clientError:newClientErrorBlk(404)
                       authenticationRequired:nil
                                  serverError:newServerErrorBlk(-1)
                             unavailableError:newServerUnavailableBlk(nil, [NSNumber numberWithInt:90])
                            connectionFailure:newConnFailureBlk(-1)
                                      timeout:60
                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                 otherHeaders:nil];
            expectedFutureFlags(NO, NO, NO, NO, NO, NO, YES, NO, 60);
          });

        it(@"Works in the event of a 503 with a date for the retry-after.", ^{
            NSString *path = @"/users/u10391";
          [PEHttpResponseSimulator simulateResponseFromXml:contentsOfMockResponse(@"http-response.503.1")
                                     pathsRelativeToBundle:[NSBundle bundleForClass:[self class]]
                                            requestLatency:0
                                           responseLatency:0];
          NSDate *expectedRetryAfter = [[HCRelationExecutor dateFormatterWithPattern:@"EEE',' dd MMM yyyy HH':'mm':'ss z"]
                                        dateFromString:@"Fri, 04 Nov 2014 23:59:59 GMT"];
          [relExecutor doGetForTargetResource:[[HCResource alloc] initWithMediaType:mediaType uri:url(path)]
                                   parameters:nil
                              ifModifiedSince:nil
                             targetSerializer:jsonSerializer
                                 asynchronous:YES
                              completionQueue:nil
                                authorization:nil
                                      success:newEmptyGetSuccessBlk()
                                  redirection:newRedirectBlk(nil, NO, NO)
                                  clientError:newClientErrorBlk(404)
                       authenticationRequired:nil
                                  serverError:newServerErrorBlk(-1)
                             unavailableError:newServerUnavailableBlk(expectedRetryAfter, nil)
                            connectionFailure:newConnFailureBlk(-1)
                                      timeout:60
                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                 otherHeaders:nil];
          expectedFutureFlags(NO, NO, NO, NO, NO, NO, YES, NO, 60);
          });
      });

    context(@"Timeouts", ^{
        it(@"Works in the event of a simulated time out.", ^{
            NSString *path = @"/users";
            [PEHttpResponseSimulator simulateConnectionTimedOutForRequestUrl:url(path)
                                                        andRequestHttpMethod:@"GET"];
          [relExecutor doGetForTargetResource:[[HCResource alloc] initWithMediaType:mediaType uri:url(path)]
                                   parameters:nil
                              ifModifiedSince:nil
                             targetSerializer:jsonSerializer
                                 asynchronous:YES
                              completionQueue:nil
                                authorization:nil
                                      success:newEmptyGetSuccessBlk()
                                  redirection:newRedirectBlk(nil, NO, NO)
                                  clientError:newClientErrorBlk(404)
                       authenticationRequired:nil
                                  serverError:newServerErrorBlk(-1)
                             unavailableError:newServerUnavailableBlk(nil, nil)
                            connectionFailure:newConnFailureBlk(NSURLErrorTimedOut)
                                      timeout:60
                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                 otherHeaders:nil];
          expectedFutureFlags(NO, NO, NO, NO, NO, NO, NO, YES, 60);
          });

        it(@"Works in the event of a time out not explicitly simulated", ^{
            NSString *path = @"/users/u10391";
            // by the way, this won't work if you set responseLatency instead of
            // request latency.  The reason is, if you set response latency
            // only, response-data, chunked, will be returned in small
            // incrementals over the lifespan of the timeout value; since data
            // are being returned, the timeout value configured on the
            // doGet... call will be irrelevant.  This is because the fact that
            // data is in fact being returned --- albeit slow --- negates the
            // action of the timeout set on the relation executor.  So, to
            // REALLY simulate a timeout, w/out using the simulator's "simulate
            // timeout" class method, you have to set the request latency, not
            // the response latency.
            [PEHttpResponseSimulator
              simulateResponseFromXml:contentsOfMockResponse(@"http-response.200")
                pathsRelativeToBundle:[NSBundle bundleForClass:[self class]]
                       requestLatency:20
                      responseLatency:0];
          [relExecutor doGetForTargetResource:[[HCResource alloc] initWithMediaType:mediaType uri:url(path)]
                                   parameters:nil
                              ifModifiedSince:nil
                             targetSerializer:jsonSerializer
                                 asynchronous:YES
                              completionQueue:nil
                                authorization:nil
                                      success:newEmptyGetSuccessBlk()
                                  redirection:newRedirectBlk(nil, NO, NO)
                                  clientError:newClientErrorBlk(-1)
                       authenticationRequired:nil
                                  serverError:newServerErrorBlk(-1)
                             unavailableError:newServerUnavailableBlk(nil, nil)
                            connectionFailure:newConnFailureBlk(NSURLErrorTimedOut)
                                      timeout:5
                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                 otherHeaders:nil];
            expectedFutureFlags(NO, NO, NO, NO, NO, NO, NO, YES, 60);
          });
      });

    context(@"schemeForAuthHeaderValue: Helper", ^{
        it(@"Works when scheme and realm are present.", ^{
            NSString *scheme =
              [HCRelationExecutor
                schemeForAuthHeaderValue:@"Basic realm=\"My Realm\""];
            [scheme shouldNotBeNil];
            [[scheme should] equal:@"Basic"];
          });

        it(@"Works when scheme is present, and realm is not present.", ^{
            NSString *scheme =
              [HCRelationExecutor
                schemeForAuthHeaderValue:@"MyCustomScheme"];
            [scheme shouldNotBeNil];
            [[scheme should] equal:@"MyCustomScheme"];
          });
      });

    context(@"realmForAuthHeaderValue: Helper", ^{
        it(@"Works when realm is present.", ^{
            NSString *realm =
              [HCRelationExecutor
                realmForAuthHeaderValue:@"Basic realm=\"My Realm\""];
            [realm shouldNotBeNil];
            [[realm should] equal:@"My Realm"];
          });

        it(@"Works when realm is not present.", ^{
            [[HCRelationExecutor realmForAuthHeaderValue:@"MyCustomScheme"]
              shouldBeNil];
          });

        it(@"Works when auth parameters are present.", ^{
            NSString *realm =
              [HCRelationExecutor
                 realmForAuthHeaderValue:@"MyCustomScheme realm=\"realm alpha\",param1=\"param2\""];
            [realm shouldNotBeNil];
            [[realm should] equal:@"realm alpha"];
          });
      });
  });

SPEC_END
