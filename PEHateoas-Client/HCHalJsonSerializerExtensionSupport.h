//
//  HCHalJsonSerializerExtensionSupport.h
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

/**
 Convenience class for creating custom serializers that extend from the HAL
 Json serializer class.  Sub-classes need only override 2 simple methods for
 achieving serialization / deserialization support.  Sub-classes essentially
 need only provide a way to map an NSDictionary to/from their model.
 */
@interface HCHalJsonSerializerExtensionSupport : HCHalJsonSerializer

#pragma mark - Serialization (Resource Model -> Dictionary)

/**
 Returns a dictionary from the given resource model object.
 @param resourceModel The model object.
 @return A dictionary representation of the given resource model object.
 */
- (NSDictionary *)dictionaryWithResourceModel:(id)resourceModel;

#pragma mark - Deserialization (Dictionary -> Resource Model)

/**
 Returns a resource model object from the given dictionary.
 @param resourceDictionary Dictionary representation of a model object.
 @return The model object represented by the given dictionary.
 */
- (id)resourceModelWithDictionary:(NSDictionary *)resourceDictionary
                        relations:(NSDictionary *)relations
                        mediaType:(HCMediaType *)mediaType
                         location:(NSString *)location
                     lastModified:(NSDate *)lastModified;

@end
