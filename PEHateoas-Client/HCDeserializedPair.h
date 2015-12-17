//
//  HCDeserializedPair.h
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

/**
 An abstraction representing the return-type of deserializing an HTTP response.
 An HTTP response can be thought of consisting of 2 logical pieces: an entity
 and a set of relations in which the entity is the subject resource.  The
 nomencalture given to entity is resource model.
 */
@interface HCDeserializedPair : NSObject

#pragma mark - Initializers

/**
 Creates and returns a new deserialized-pair instance with the given resource
 model and relation collection.
 @param resourceModel the model object that represents the deserialized entity
 @param relations the collection of deserialized relations from the HTTP
 response
 @return a new deserialized-pair instance
 */
- (id)initWithResourceModel:(id)resourceModel
                  relations:(NSDictionary *)relations;

/**
 The deserialized entity from the HTTP response as a model object.
 */
@property (nonatomic, readonly) id resourceModel;

/**
 The set of relations deserialized from the HTTP response.
 */
@property (nonatomic, readonly) NSDictionary *relations;

@end
