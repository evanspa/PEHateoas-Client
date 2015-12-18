//
//  HCHalJsonSerializer.m
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

#import "HCHalJsonSerializer.h"
#import "HCRelation.h"
#import "HCUtils.h"
#import "HCDeserializedPair.h"
#import "HCMediaType.h"
#import "HCCharset.h"
#import "HCResource.h"

NSString * const HCEmbeddedResourceMediaTypeKey = @"media-type";
NSString * const HCEmbeddedResourceLocationKey = @"location";
NSString * const HCEmbeddedResourceLastModifiedKey = @"last-modified";
NSString * const HCEmbeddedResourcePayloadKey = @"payload";
NSString * const HCEmbeddedResource = @"_embedded";

@implementation HCHalJsonSerializer

#pragma mark - Private Helpers

- (NSDictionary *)deserializeRelationsFromResource:(NSDictionary *)resource
                                 resourceMediaType:(HCMediaType *)mediaType
                                       resourceURL:(NSURL *)subjectResourceUrl {
  __block NSDictionary *relsDict = [resource objectForKey:@"_links"];
  __block NSMutableDictionary *relations =
    [[NSMutableDictionary alloc] initWithCapacity:[relsDict count]];
  [relsDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
      NSDictionary *relDict = (NSDictionary *)obj;
      NSString *relName = (NSString *)key;
      NSString *targetResMtStr = [relDict objectForKey:@"type"];
      HCMediaType *targetResMt = mediaType; // default to resource's mt
      if (targetResMtStr) {
        targetResMt = [HCMediaType MediaTypeFromString:targetResMtStr];
      }
      NSURL *targetResUri = nil;
      NSString *targetResUriStr = [relDict objectForKey:@"href"];
      if (targetResUriStr) {
        targetResUri = [HCUtils ResourceURLFromString:targetResUriStr
                                 enclosingResourceURL:subjectResourceUrl];
      }
      HCResource *subjectRes =
        [[HCResource alloc] initWithMediaType:mediaType uri:subjectResourceUrl];
      HCResource *targetRes =
        [[HCResource alloc] initWithMediaType:targetResMt uri:targetResUri];
      HCRelation *relation = [[HCRelation alloc] initWithName:relName
                                              subjectResource:subjectRes
                                               targetResource:targetRes];
      [relations setObject:relation forKey:relName];
    }];
  return relations;
}

- (NSDictionary *)pruneLinksFromResource:(NSDictionary *)resource {
  NSMutableDictionary *mutResourceDict = [resource mutableCopy];
  [mutResourceDict removeObjectForKey:@"_links"];
  return mutResourceDict;
}

#pragma mark - Serialization (model -> HTTP request entity)

- (NSData *)serializeResourceModelToTextData:(id)resourceModel {
  if ([resourceModel isKindOfClass:[NSDictionary class]]) {
    return [NSJSONSerialization dataWithJSONObject:resourceModel
                                           options:NSJSONWritingPrettyPrinted
                                             error:nil];
  } else {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"the given resource model needs to \
be an NSDictionary"
                                 userInfo:nil];
  }
}

#pragma mark - Deserialization (HTTP response entity -> model+relations)

- (HCDeserializedPair *)deserializeResourceFromTextData:(NSData *)data
                                      resourceMediaType:(HCMediaType *)mediaType
                                            resourceURL:(NSURL *)url
                                           httpResponse:(NSHTTPURLResponse *)httpResponse {
  if (data && ([data length] > 0)) {
    
    // TODO - hmmm.  JSONObjectWithData:options:error: ASSUMES that 'data' is
    // UTF-* encoded.  It would be better to inspect the 'charset=' part of the
    // Content-Type response header.  Oh well.  Not going to worrry about this.
    
    NSDictionary *jsonResponse =
      [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSURL *subjectResourceUrl = url;
    if ([httpResponse statusCode] == 201) {
      NSString *location = [HCUtils locationFromResponse:httpResponse];
      if (location) {
        subjectResourceUrl = [NSURL URLWithString:location];
      }
    }
    if (mediaType && [HCUtils isSuccessResponse:httpResponse]) { // only do check if we got a success response
      NSAssert([mediaType isEqualToMediaType:[self mediaType]], @"The media \
type of the HTTP response: [%@] does not match with the media type associated \
with this serializer: [%@]", mediaType, [self mediaType]);
    }
    return [[HCDeserializedPair alloc]
              initWithResourceModel:
                [self pruneLinksFromResource:jsonResponse]
              relations:
                [self deserializeRelationsFromResource:jsonResponse
                                     resourceMediaType:mediaType
                                           resourceURL:subjectResourceUrl]];
  }
  return nil;
}

- (HCDeserializedPair *)deserializeEmbeddedResource:(id)readTextData {
  NSDictionary *embeddedRes = (NSDictionary *)readTextData;
  HCMediaType *mediaType = [HCMediaType MediaTypeFromString:[embeddedRes objectForKey:HCEmbeddedResourceMediaTypeKey]];
  NSURL *location = [NSURL URLWithString:[embeddedRes objectForKey:HCEmbeddedResourceLocationKey]];
  NSDictionary *resourcePayload = [embeddedRes objectForKey:HCEmbeddedResourcePayloadKey];
  return [[HCDeserializedPair alloc]
          initWithResourceModel:
            [self pruneLinksFromResource:resourcePayload]
          relations:
            [self deserializeRelationsFromResource:resourcePayload
                                 resourceMediaType:mediaType
                                       resourceURL:location]];
}

@end
