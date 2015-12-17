//
//  HCFakeResourceSerializer.h
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
#import "HCResourceSerializerSupport.h"
#import "HCDeserializedPair.h"

/**
 Implementation of HCResourceSerializer for use in unit testing (e.g., use
 in the AFNetworking-serializer implementations).
 */
@interface HCFakeResourceSerializer : HCResourceSerializerSupport

/**
 The data set will be returned by subsequent calls to the
 serializeResourceModelToTextData: message.
 @param fakeData the data to be returned by subsequent calls to the
 serializeResourceModelToTextData: message
 */
- (void)setFakeSerializationResult:(NSData *)fakeData;

/**
 The deserialized pair to be returned by subsequent calls to the
 deserializeResourceFromTextData: message.
 @param fakePair the pair object to be returned by subsequent calls to the
 deserializeResourceFromTextData: message
 */
- (void)setFakeDeserializedPairResult:(HCDeserializedPair *)fakePair;

@end
