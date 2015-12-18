//
//  HCDefs.h
//  PEHateoas-Client
//
//  Created by Paul Evans on 12/18/15.
//  Copyright © 2015 Paul Evans. All rights reserved.
//

@class HCAuthentication;

typedef void (^HCActionForEmbeddedResource)(id resourceModel, id embeddedResourceModel);

/**
 *  Success block type for GET requests.
 *  @param location      The value of the "Location" header, if present.
 *  @param resourceModel The resource model object parsed from the response body.
 *  @param lastModified  The value of the "Last-Modified" header, if present.
 *  @param relations     The set of link relations parsed from the response body.
 *  @param resp          The underlying HTTP response.
 */
typedef void (^HCGETSuccessBlk)(NSURL *location,
                                id resourceModel,
                                NSDate *lastModified,
                                NSDictionary *relations,
                                NSHTTPURLResponse *resp);

/**
 Success block type for POST requests.  Block parameters:
 + *location* - The URI of the newly created resource.
 + *lastModified* - The last modified date parsed from the associated response header.
 + *relations* - The set of link relations parsed from the response body.
 + *resp* - The raw HTTP response.
 */
typedef void (^HCPOSTSuccessBlk)(NSURL *location,
                                 id resourceModel,
                                 NSDate *lastModified,
                                 NSDictionary *relations,
                                 NSHTTPURLResponse *resp);

/**
 Success block type for PUT requests.  Block parameters:
 + *location* - The URI of the updated resource.
 + *lastModified* - The last modified date parsed from the associated response header.
 + *relations* - The set of link relations parsed from the response body.
 + *resp* - The raw HTTP response.
 */
typedef void (^HCPUTSuccessBlk)(NSURL *location,
                                id resourceModel,
                                NSDate *lastModified,
                                NSDictionary *relations,
                                NSHTTPURLResponse *resp);

/**
 Success block type for DELETE requests.  Block parameters:
 + *resp* - The raw HTTP response.
 */
typedef void (^HCDELETESuccessBlk)(NSHTTPURLResponse *resp);

/**
 + *location* - The subject-resource's new location in the event that movedPermanently is YES.
 + *movedPermanently* - Whether or not the subject-resource has been moved (has a new global URI)
 + *notModified* - Whether or not the subject-resource has not been modified based on conditional-criteria in GET request
 + *resp* - The raw HTTP response.
 */
typedef void (^HCRedirectionBlk)(NSURL *location,
                                 BOOL movedPermanently,
                                 BOOL notModified,
                                 NSHTTPURLResponse *resp);

/**
 Error block type in the event of a client error (4XX response code).  Block
 parameters:
 + *resp* - The raw HTTP response.
 */
typedef void (^HCClientErrorBlk)(NSHTTPURLResponse *resp);

/**
 Client error block type in the event the server rejects the request because
 authentication is required on the part of the client.  Block parameters:
 + *auth* - Represents the authentication requirement (encapsulates the
 authentication scheme, realm and auth parameters).
 + *resp* - The raw HTTP response.
 */
typedef void (^HCAuthReqdErrorBlk)(HCAuthentication *auth, NSHTTPURLResponse *resp);

/**
 Error block type in the event of a server error (5XX response code).  Block
 parameters:
 + *resp* - The raw HTTP response.
 */
typedef void (^HCServerErrorBlk)(NSHTTPURLResponse *resp);

/**
 Error block type in the event the server responds with a 409 indicating that
 the resource on the server was modified more recently than the client last
 fetched the resource, and thus the PUT / DELETE cannot proceed without the
 client first resolving the conflict.
 */
typedef void (^HCConflictBlk)(NSURL *location,
                              id resourceModel, // the origin server's latest copy of the subject-resource
                              NSDate *lastModified, // the last-modified date of the returned resource
                              NSDictionary *relations,
                              NSHTTPURLResponse *resp);

/**
 Error block type in the event of a server unavailable (503 response code) and
 there is a retry-after header present.
 */
typedef void (^HCServerUnavailableBlk)(NSDate *retryAfter, NSHTTPURLResponse *resp);

/**
 Error Block type in the event there's a connection failure .  Block
 parameters:
 + *nsurlErr* - The NSURL error code associated with the connection failure.
 */
typedef void (^HCConnFailureBlk)(NSInteger nsurlErr);
