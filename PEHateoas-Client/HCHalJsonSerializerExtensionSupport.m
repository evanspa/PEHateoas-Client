//
//  HCHalJsonSerializerExtensionSupport.m
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

#import "HCHalJsonSerializerExtensionSupport.h"
#import "HCUtils.h"
#import "HCDeserializedPair.h"
#import "HCMediaType.h"
#import "HCCharset.h"
#import "HCDefs.h"

@implementation HCHalJsonSerializerExtensionSupport

#pragma mark - Helper

- (HCDeserializedPair *)deserializePrunedResourceModel:(HCDeserializedPair *)pair
                                             mediaType:(HCMediaType *)mediaType
                                              location:(NSString *)location
                                          lastModified:(NSDate *)lastModified {
  if (pair) {
    NSDictionary *resourceJsonObj = [pair resourceModel];
    id resourceModel =
      [self resourceModelWithDictionary:resourceJsonObj
                              relations:[pair relations]
                              mediaType:mediaType
                               location:location
                           lastModified:lastModified];
    id embeddedResources = [resourceJsonObj objectForKey:HCEmbeddedResource];
    if (embeddedResources) {
      for (NSDictionary *embeddedRes in embeddedResources) {
        NSString *mediaType = [embeddedRes objectForKey:HCEmbeddedResourceMediaTypeKey];
        id<HCResourceSerializer> serializer = [[self embeddedSerializers] objectForKey:mediaType];
        if (serializer) {
          id embeddedModel = [[serializer deserializeEmbeddedResource:embeddedRes] resourceModel];
          HCActionForEmbeddedResource action = [[self embeddedResourceActions] objectForKey:mediaType];
          if (action) {
            action(resourceModel, embeddedModel);
          }
        }
      }
    }
    return [[HCDeserializedPair alloc] initWithResourceModel:resourceModel
                                                   relations:[pair relations]];
  }
  return nil;
}

#pragma mark - Serialization (HCResourceSerialization Protocol)

- (NSData *)serializeResourceModelToTextData:(id)resourceModel {
  NSDictionary *resourceDict = [self dictionaryWithResourceModel:resourceModel];
  return [NSJSONSerialization dataWithJSONObject:resourceDict
                                         options:NSJSONWritingPrettyPrinted
                                           error:nil];
}

#pragma mark - Deserialization (HCResourceSerialization Protocol)

- (HCDeserializedPair *)deserializeResourceFromTextData:(NSData *)data
                                      resourceMediaType:(HCMediaType *)mediaType
                                            resourceURL:(NSURL *)url
                                           httpResponse:(NSHTTPURLResponse *)httpResponse {
  HCDeserializedPair *pair =
    [super deserializeResourceFromTextData:data
                         resourceMediaType:mediaType
                               resourceURL:url
                              httpResponse:httpResponse];
  return [self deserializePrunedResourceModel:pair
                                    mediaType:[HCUtils mediaTypeFromResponse:httpResponse]
                                     location:[HCUtils locationFromResponse:httpResponse]
                                 lastModified:[HCUtils lastModifiedFromResponse:httpResponse]];
}

- (HCDeserializedPair *)deserializeEmbeddedResource:(id)readTextData {
  HCDeserializedPair *pair = [super deserializeEmbeddedResource:readTextData];
  NSDictionary *embeddedRes = (NSDictionary *)readTextData;
  return [self deserializePrunedResourceModel:pair
                                    mediaType:[HCMediaType MediaTypeFromString:[embeddedRes objectForKey:HCEmbeddedResourceMediaTypeKey]]
                                     location:[embeddedRes objectForKey:HCEmbeddedResourceLocationKey]
                                 lastModified:[HCUtils rfc7231DateFromString:[embeddedRes objectForKey:HCEmbeddedResourceLastModifiedKey]]];
}

#pragma mark - Serialization (Resource Model -> Dictionary)

- (NSDictionary *)dictionaryWithResourceModel:(id)resourceModel {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must \
override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];

}

#pragma mark - Deserialization (Dictionary -> Resource Model)

- (id)resourceModelWithDictionary:(NSDictionary *)resourceDictionary
                        relations:(NSDictionary *)relations
                        mediaType:(HCMediaType *)mediaType
                         location:(NSString *)location
                     lastModified:(NSDate *)lastModified {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must \
override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}

@end
