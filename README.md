# PEHateoas-Client

[![Build Status](https://travis-ci.org/evanspa/PEHateoas-Client.svg)](https://travis-ci.org/evanspa/PEHateoas-Client)

PEHateoas-Client is an iOS static library for simplifying the consumption
hypermedia REST APIs.  PEHateoas-Client is built on top of
[AFNetworking](https://github.com/AFNetworking/AFNetworking).  Currently
PEHateoas-Client supports a variation and subset of
[HAL](http://stateless.co/hal_specification.html) (*we ignore CURIEs and
we support a slight modification to the notion of embedded resources*).

PEHateoas-Client is part of the
[PE* iOS Library Suite](#pe-ios-library-suite).

**Table of Contents**

- [Motivation](#motivation)
  - [HATEOAS Resources](#hateoas-resources)
- [Design](#design)
  - [Primary Abstractions](#primary-abstractions)
    - [HCMediaType](#hcmediatype)
    - [HCResource](#hcresource)
    - [HCRelation](#hcrelation)
    - [HCRelationExecutor](#hcrelationexecutor)
    - [HCAuthentication and HCAuthorization](#hcauthentication-and-hcauthorization)
  - [Block Types of HCRelationExecutor Functions](#block-types-of-hcrelationexecutor-functions)
      - [HCGETSuccessBlk](#hcgetsuccessblk)
- [Serializers](#serializers)
    - [Embedded Resources](#embedded-resources)
- [Example Usage](#example-usage)
  - [GET](#get)
  - [POST](#post)
- [Installation with CocoaPods](#installation-with-cocoapods)
- [PE* iOS Library Suite](#pe-ios-library-suite)

## Motivation

Simply put, in order to easily consume hypermedia REST APIs within iOS
applications.  The name, *PEHateoas-Client* is derived from the acronym
[HATEOAS](http://en.wikipedia.org/wiki/HATEOAS): **Hypermedia as the Engine of
Application State**, is an approach to RESTful web service design such that URL
endpoints of resources are not known a priori; instead, clients are aware of a starting poing
URL as well as the set of link relations and media types supported by the web
service.

### HATEOAS Resources

+ [REST APIs must be hypertext-driven](http://roy.gbiv.com/untangled/2008/rest-apis-must-be-hypertext-driven) -
  Roy Fielding's popular blog entry on hypermedia-driven REST APIs
+ [Fielding's original REST paper](http://www.ics.uci.edu/~fielding/pubs/dissertation/top.htm)
+ [REST in Practice](http://www.amazon.com/REST-Practice-Hypermedia-Systems-Architecture/dp/0596805829/ref=sr_1_1?s=books&ie=UTF8&qid=1422885902&sr=1-1&keywords=rest+in+practice) -
  I found this book particularly insightful for learning about hypermedia-driven
  REST design

## Design

### Primary Abstractions

The following are the primary abstractions of PEHateoas-Client, manifesting as
Objective-C classes.

#### HCMediaType

Represents an
[internet media type](http://en.wikipedia.org/wiki/Internet_media_type).  Every
HTTP resource has a media type associated with it.

#### HCResource

Represents an HTTP resource.  A resource is defined as a piece of typed content
(typed with a media type), and having a URI.  A resource may also contain a set
of embedded links.  Each link represents a relationship between the enclosing
resource, and some target resource.

#### HCRelation

Represents a hypermedia link relation.  (* Note: 'relation' here does not having
the same meaning as it does in mathematics.  It would be more insightful to think
of a hypermedia link relation as a **relationship**.*) A hypermedia link relation is
binary in nature.  In addition to having a name, a relation has both a source
resource and a target resource.  In the context of the
[HAL format](http://stateless.co/hal_specification.html), a relation takes the
form of an object found within a `_links` JSON entry.  A `_links` JSON object is
a collection of JSON objects; the key of each object within the `_links` object
is the link relation name.  For example, given the following JSON:
```json
{ "fuelstation-name": "7-Eleven",
  "price-per-gallon": 2.89,
  "car-wash-pergallon-discount": 0.15,
  "_links": {
    "self": {
        "href": "https://fp.example.com/fuelstations/fs291410",
        "type": "application/vnd.fuelstation.example.com-v1.0+json"
    },
    "purchase_logs": {
        "href": "https://fp.example.com/fuelstations/fs291410/purchase-logs",
        "type": "application/vnd.fplog.example.com-v1.0+json"}}}
```
We have a fuel station resource containing 2 hypermedia links.  The relation
names of the links are: *self*, and *purchase_logs*.  The self relation has a
name of "self"; its source AND target resource is the enclosing resource (so
it's self-referential).  The URI of our example resource above is the value of
the `href` attribute of the `self` link.  The purchase logs relation has a name
of "purchase_logs"; its source resource is the enclosing resource and its target
resource has a URI of
`https://fp.example.com/fuelstations/fs291410/purchase-logs` and type:
`application/vnd.fuelstation.example.com-v1.0+json`.

#### HCRelationExecutor

The means by which we navigate a link relation to its target resource.  Usually
when encountering a resource, and inspecting its embedded set of link relations,
we desire to *navigate* to the target resources of those links.  Here,
*navigate* is used in a general sense.  It could mean any of the following
standard HTTP operations:
+ POST, GET, PUT, DELETE, etc.

An instance of HCRelationExecutor is used to navigate to the target resource of
a link relation.  HCRelationExecutor exposes the following functions:
+ `doPostForTargetResource: ...`
+ `doGetForTargetResource: ...`
+ `doPutForTargetResource: ...`
+ `doDeleteForTargetResource: ...`

These functions take a pretty large set of parameters.
[Check out the API docs](http://cocoadocs.org/docsets/PEHateoas-Client) for
details.

#### HCAuthentication and HCAuthorization

An instance of `HCAuthentication` is received in a `HCAuthReqdErrorBlk` block
(*described below*) upon issuing an HTTP request, and a 401 (*Unauthorized*) is
returned.  The authentication instance contains the parsed bits of the
`WWW-Authenticate` response header (i.e., the scheme and realm).

An instance of `HCAuthorization` can be supplied as a parameter to each of the
`doXXXTargetResource: ...` methods in `HCRelationExecutor`.  When supplied, an
`Authorization` header will be included in the HTTP request.  An authorization
instance typically encapsulates 3 parts: a scheme, parameters and values.  A
factory function exists to simplify the creation of a single param/value pair
`HCAuthorization` instance.

### Block Types of HCRelationExecutor Functions

##### HCGETSuccessBlk

Success / completion block for `doGetForTargetResource:...`.  In this block,
you'll get most of the important bits from the HTTP response for free,
including:
+ the location (NSURL*) of the fetched resource
+ model object (parsed from the response body using your provided serializer)
+ the set of link relations (as an NSDictionary*) embedded in the resource body
+ the last-modified date of the fetched resource (as an NSDate*)
+ the raw HTTP response (NSHTTPURLResponse *) itself (in case you need it)

The completion block types associated with the other relation executor functions
provide the same general parameters.  The block types are: `HCPOSTSuccessBlk`,
`HCPUTSuccessBlk`, `HCDELETESuccessBlk`, etc.

In addition to having native support for HATEOAS, PEHateoas-Client is generally
a sweet, sugary layer on top of AFNetworking.  Whereas AFNetworking provides 2
basic completion block types for its functions (for success and success),
PEHateoas-Client provides completion blocks for the following situations:
+ **Success block** (for any 2XX response codes)
+ **Authentication-required block** (for a 401 response code) - *includes an
  HCAuthentiation parameter which encapsulates the parsed bits of the
  "WWW-Authenticate" header; i.e. the scheme and realm parts*
+ **Redirection block** (for all 3XX response codes except 301/302/303) - *for
  301/302/303 AFNetworking will automatically follow the redirection link*
+ **Conflict block** (for a 409 response)
+ **Client error block** (for all other 4XX response codes)
+ **Server unavailable block** (for a 503 response) - *includes an NSDate parameter as the
  retry-after date (if "Retry-After" header is present)*
+ **Server error block** (for all other 5XX response codes)

As you can see, PEHateoas-Client does some rudimentary parsing of the HTTP
response, and invokes the provided blocks accordingly.  Each block type receives
the raw NSHTTPURLResponse in case further traversal is desired.

## Serializers

PEHateoas-Client allows you to configure serializers for both serializing a
model object for inclusion in an HTTP request body (for POST and PUT requests)
as well as deserializing a response body (if present) to a model object.

Out of the box, a concrete serializer, `HCHalJsonSerializer`, is provided for a subset of the
[JSON-based HAL format](http://stateless.co/hal_specification.html) (*CURIEs are
ignored*).  It should be noted that this serializer can be used even if the
media type of your resources is not `application/hal+json`.

When using the `HCHalJsonSerializer` serializer, the model parameter of
`HCGETSuccessBlk` blocks will simply be an NSDictionary of the parsed JSON
body (with the `_links` entry omitted).  You can override this behavior by
providing your own custom serializer.  If instead of receiving an NSDictionary
as the model object parameter of success blocks you wanted to use your own
custom model objects (*which you've presumably created to model your problem
domain*), you can subclass `HCHalJsonSerializerExtensionSupport`.  You have to override 2 methods:
+ `dictionaryWithResourceModel:` - this is to serialize your model object to an
  NSDictionary (*which will then be converted to JSON on the wire*)
+ `resourceModelWithDictionary:relations:mediaType:location:lastModified:` -
  this is to deserialize an NSDictionary (which came from the JSON response
  body, minus the `_links` entry) to a model object of yours (*when doing this
  deserialization, you'll also have the parsed link relations, media type,
  location and last-modified date - if present, of course*)

#### Embedded Resources

The HAL format allows for resources to be embedded within resources (using the
`_embedded` key).  PEHateoas-Client has a slightly modified conception of
embedded resources compared to the HAL format.  Building on our fuel station
resource, the following is an example of embedding as understood by
PEHateoas-Client:
```json
{ "fuelstation-name": "7-Eleven",
  "price-per-gallon": 2.89,
  "car-wash-pergallon-discount": 0.15,
  "_links": {
    "self": {
        "href": "https://fp.example.com/fuelstations/fs291410",
        "type": "application/vnd.fuelstation.example.com-v1.0+json"
    },
    "purchase_logs": {
        "href": "https://fp.example.com/fuelstations/fs291410/purchase-logs",
        "type": "application/vnd.fplog.example.com-v1.0+json"}},
  "_embedded": [
    {"media-type": "application/vnd.fplog.example.com-v1.0+json",
     "location": "",
     "last-modified": "",
     "paylaod": {
       "log-date": "",
       "num-gallons-purchased": 14.9,
       "odometer-reading": 52981}},
    ...
    {"media-type": "application/vnd.envlog.example.com-v1.0+json",
     "location": "",
     "last-modified": "",
     "paylaod": {
       "log-date": "",
       "outside-temperature": 72,
       "atmospheric-pressure": 101325}},
    ...
  ]}
```
In our example above, the value of the `_embedded` entry is an array of objects (*in contrast to HAL
where the value of the `_embedded` entry would be another object*).  An array
seemed like a better fit for _embedded, so that's what we went with.  Also, each
embedded object within the array has 3 useful pieces of metadata: `media-type`,
`location` and `last-modified`.  The `payload` entry contains the actual content
of the embedded resource.

In order for your serializer be able to cope with embedded resources, when
constructing it, simply supply an appropriate dictionary to the
`serializersForEmbeddedResources` and `actionsForEmbeddedResources` parts of
`HCResourceSerializerSupport`'s initializer (`HCHalJsonSerializer` extends from
`HCResourceSerializerSupport`).  Lets look at an example.  Assume you have the
following model classes:

```objective-c
@interface FPFuelPurchaseLog : NSObject
@property (nonatomic, readonly) NSDate *logDate;
@property (nonatomic, readonly) NSDecimalNumber *odometerReading;
@property (nonatomic, readonly) NSDecimalNumber *numGallonsPurchased;
@end

@interface FPFuelStation : NSObject
@property (nonatomic, readonly) NSString *fuelStationName;
@property (nonatomic, readonly) NSDecimalNumber *pricePerGallon;
@property (nonatomic, readonly) NSArray *fpLogs;

- (void)addFpLog:(FPFuelPurchaseLog *)fpLog;
@end
```
And you have 2 serializer classes (for each of your model classes).  Each
serializer class is only concerned about the immediate, direct non-collection
properties of their corresponding model classes.  I.e., the fuel station
serializer does not care about fuel purchase log instances (*even though it has
a reference to an NSArray of them*).

```objective-c
@interface FPFuelPurchaseLogSerializer : HCHalJsonSerializerExtensionSupport
@end

@interface FPFuelStationSerializer : HCHalJsonSerializerExtensionSupport
@end
```
And now the code that leverages the serializers:

```objective-c
// define our serializers
HCMediaType *fpLogMediaType = [HCMediaType mediaTypeFromString:@"application/vnd.fp.example.com-v1.0+json"];
FPFuelPurchaseLogSerializer *fpLogSerializer =
  [[FPFuelPurchaseLogSerializer alloc] initWithMediaType:fpLogMediaType
                                                 charset:[HCCharset UTF8]
                         serializersForEmbeddedResources:@{} // fplog resources will NOT have embedded resources
                             actionsForEmbeddedResources:@{}];

HCMediaType *fuelStationMediaType = [HCMediaType mediaTypeFromString:@"application/vnd.fp.example.com-v1.0+json"];
HCActionForEmbeddedResource actionForEmbeddedFpLog = ^(id fuelStation, id embeddedFpLog) {
  [(FPFuelStation *)fuelStation addFpLog:embeddedFpLog];
};
FPFuelStationSerializer *fuelStationSerializer =
  [[FPFuelStationSerializer alloc] initWithMediaType:fuelStationMediaType
                                             charset:[HCCharset UTF8]
                     serializersForEmbeddedResources:@{[fpLogMediaType description] : fpLogSerializer}
                         actionsForEmbeddedResources:@{[fpLogMediaType description] :
                         actionForEmbeddedFpLog}];

// deserialize our fuel station JSON
NSString *fuelStationJsonAsStr = ...; // assume fuelStationJsonAsStr now holds our fuel station JSON defined above
NSDictionary *fuelStationJsonAsDict =
  [NSJSONSerialization JSONObjectWithData:[fuelStationJsonAsStr dataUsingEncoding:NSUTF8StringEncoding]
                                  options:0
                                    error:nil];
HCDeserializedPair *pair = [fuelStationSerializer deserializeEmbeddedResource:fuelStationJsonAsDict];
FPFuelStation *fuelStation = [pair resourceModel];
NSDictionary *fuelStationRels = [pair relations];
```

Our `fuelStationSerializer` is initialized such that if it encounters an
`_embedded` entry in the HAL JSON it's parsing, for each embedded resource whose
media type matches the media type encapsulated by `fpLogMediaType`,
`fpLogSerializer` will be used to deserialize it, and the result will be
provided as the 2nd parameter to our `actionForEmbeddedFpLog` block.  As you can
see, our `actionForEmbeddedFpLog` block's implementation is to add the given
`embeddedFpLog` instance to the `fuelStation`'s collection.  If it wasn't
obvious, the `fuelStation` parameter of the `actionForEmbeddedFpLog` block would
be the fuel station instance currently being parsed by the
`fuelStationSerializer`.

It should be noted that when using PEHateoas-Client, you'll never have to
manually invoke the serializer.  If fact, there is a deserialize method defined
in `HCResourceSerializer` that receives an NSHTTPURLResponse (*among others*)
and performs the deserialization; however, you don't have to call this in normal
application code.  Instead, it is performed by your `HCRelationExecutor`
instance.

## Example Usage

For the following examples, assume we have the fuel station serializers from
above in our midst.  Also assume that we have our hands on the fuel station's
URI.  (*HOW we know the fuel station's URI is a separate discussion topic.  Just
assume we know it from a previous GET request to a resource that contained it.
Remember, the REST client is endowed with the knowledge of a **starting point**
URI; so assume from this starting point, the client was able to get a handle to
the fuel station's URI through normal REST/hypermedia traversal*).

### GET

```objective-c
HCRelationExecutor *relExec =
  [[HCRelationExecutor alloc] initWithDefaultAcceptCharset:[HCCharset UTF8]
                                     defaultAcceptLanguage:@"en-US"
                                 defaultContentTypeCharset:[HCCharset UTF8]
                                  allowInvalidCertificates:NO];
NSURL *fuelStationUrl = [[NSURL alloc]initWithString:@"/fuelstations/fs291410"
                                       relativeToURL:[NSURL URLWithString:@"https://fp.example.com"]];
HCResource *fuelStationRes = [[HCResource alloc] initWithMediaType:fuelStationMediaType
                                                               uri:fuelStationUrl];
__block FPFuelStation *fetchedFuelStation;
__block NSDictionary *fuelStationRelations;
HCGETSuccessBlk successBlk = ^(NSURL *location,
                               id resourceModel,
                               NSDate *lastModified,
                               NSDictionary *relations,
                               NSHTTPURLResponse *resp) {
  fetchedFuelStation = (FPFuelStation *)resourceModel;
  fuelStationRelations = relations;
  NSLog(@"Got the fuel station and its relations!");
};
HCRedirectionBlk redirectionBlk = ^(NSURL *location,
                                    BOOL movedPermanently,
                                    BOOL notModified,
                                    NSHTTPURLResponse *resp) {
  NSLog(@"The target resource is somewhere else!");
};
HCClientErrorBlk clientErrBlk = ^(NSHTTPURLResponse *resp) {
  NSLog(@"Client error!");
};
HCAuthReqdErrorBlk authRequiredBlk = ^(HCAuthentication *auth,
                                       NSHTTPURLResponse *resp) {
  NSLog(@"Authentication required!");
};
HCServerErrorBlk serverErrBlk = ^(NSHTTPURLResponse *resp) {
  NSLog(@"Server error!");
};
HCServerUnavailableBlk serverUnavailableBlk = ^(NSDate *retryAfter,
                                                NSHTTPURLResponse *resp) {
  NSLog(@"The server is currently unavailable!");
};
HCConnFailureBlk connFailureBlk = ^(NSInteger nsurlErr) {
  NSLog(@"Connection error!");
};
[relExec doGetForTargetResource:fuelStationRes
                ifModifiedSince:nil
               targetSerializer:fuelStationSerializer
                   asynchronous:YES // YES to put AFNetworking request op onto operationQueue; NO to directly start the operation
                completionQueue:nil // run completion block on main thread
                  authorization:nil // don't supply an 'Authorization' request header
                        success:successBlk
                    redirection:redirectionBlk
                    clientError:clientErrBlk
         authenticationRequired:authRequiredBlk
                    serverError:serverErrBlk
               unavailableError:serverUnavailableBlk
              connectionFailure:connFailureBlk
                        timeout:60
                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                   otherHeaders:@{}];
```
### POST

So lets assume that at some point in the past, we got a 401 to some HTTP
request, and the `WWW-Authenticate` response header on that 401 looked like
this: `WWW-Authenticate: FPAuthToken realm='all'`  In our app we prompt the user
to log in, collect their credentials, *navigate* to some *authentication*
relation's target resource, and get back an authentication token:
`FPAUTHTKN-0291034K-ASNLUS-ZDLSI920`.  We want to include this token in our POST
example.

Where applicable, we'll be reusing some completion blocks we defined above in
our GET example.  We'll also be using our `fuelStationRelations` links
collection we fetched above in our `HCGETSuccessBlk`.  The following shows doing
a POST to create a new fuel purchase log against our fetched fuel station.

```objective-c
HCRelation *purchaseLogsRel = [fuelStationRelations objectForKey:@"purchase_logs"];
FPFuelPurchaseLog *fpLog = [FPFuelPurchaseLog makeWithLogDate:[NSDate date]
                                              odometerReading:@(25004.2)
                                          numGallonsPurchased:@(14.7)];
HCPOSTSuccessBlk successBlk = ^(NSURL *location,
                                id resourceModel,
                                NSDate *lastModified,
                                NSDictionary *relations,
                                NSHTTPURLResponse *resp) {
  if (resourceModel) {
    FPFuelPurchaseLog *newFpLog = (FPFuelPurchaseLog *)resourceModel; // if the created fpLog is echoed back in the response
    NSLog(@"Our newly-minted fpLog instance! %@", newFpLog);
  }
};
HCAuthorization *authorization = [HCAuthorization authWithScheme:@"fp-auth"
                                             singleAuthParamName:@"fp-token"
                                                  authParamValue:@"FPAUTHTKN-0291034K-ASNLUS-ZDLSI920"];
[relExec doPostForTargetResource:[purchaseLogsRel target
              resourceModelParam:fpLog // the model object to be serialized and become the body of the request
                 paramSerializer:fpLogSerializer // serializes the resourceModelParam to be the body of the request
        responseEntitySerializer:fpLogSerializer // if present, deserializes the response into a model object
                    asynchronous:YES // to put AFNetworking request op onto operationQueue; NO to directly start the operation
                 completionQueue:nil // run completion block on main thread
                   authorization:authorization
                         success:successBlk
                     redirection:redirectionBlk
                     clientError:clientErrBlk
          authenticationRequired:authRequiredBlk
                     serverError:serverErrBlk
                unavailableError:serverUnavailableBlk
               connectionFailure:connFailureBlk
                         timeout:60
                    otherHeaders:@{}];
```

## Installation with CocoaPods

```ruby
pod 'PEHateoas-Client', '~> 1.0.17'
```

## PE* iOS Library Suite
*(Each library is implemented as a CocoaPod-enabled iOS static library.)*
+ **[PEObjc-Commons](https://github.com/evanspa/PEObjc-Commons)**: a library
  providing a set of everyday helper functionality.
+ **[PEXML-Utils](https://github.com/evanspa/PEXML-Utils)**: a library
  simplifying working with XML.  Built on top of [KissXML](https://github.com/robbiehanson/KissXML).
+ **PEHateoas-Client**: this library.
+ **[PEWire-Control](https://github.com/evanspa/PEWire-Control)**: a library for
  controlling Cocoa's NSURL loading system using simple XML files.  Built on top of [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs).
+ **[PEAppTransaction-Logger](https://github.com/evanspa/PEAppTransaction-Logger)**: a
  library client for the PEAppTransaction Logging Framework.  Clojure-based libraries exist implementing the server-side [core data access](https://github.com/evanspa/pe-apptxn-core) and [REST API functionality](https://github.com/evanspa/pe-apptxn-restsupport).
+ **[PESimu-Select](https://github.com/evanspa/PESimu-Select)**: a library
  aiding in the functional testing of web service enabled iOS applications.
+ **[PEDev-Console](https://github.com/evanspa/PEDev-Console)**: a library
  aiding in the functional testing of iOS applications.
