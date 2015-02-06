//
//  CarSerializer.m
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

#import "DummyCarSerializer.h"
#import "DummyCar.h"

@implementation DummyCarSerializer

#pragma mark - Serialization (Resource Model -> Dictionary)

- (NSDictionary *)dictionaryWithResourceModel:(id)resourceModel {
  DummyCar *c = (DummyCar *)resourceModel;
  NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
  [dictionary setObject:[c color] forKey:@"car-color"];
  [dictionary setObject:[NSNumber numberWithLong:[c numDoors]]
                 forKey:@"car-number-of-doors"];
  return dictionary;
}

#pragma mark - Deserialization (Dictionary -> Resource Model)

- (id)resourceModelWithDictionary:(NSDictionary *)resourceDictionary
                        relations:(NSDictionary *)relations
                        mediaType:(HCMediaType *)mediaType
                         location:(NSString *)location
                     lastModified:(NSDate *)lastModified {
  DummyCar *c = [[DummyCar alloc] init];
  [c setLocation:location];
  [c setMediaType:mediaType];
  [c setLastModified:lastModified];
  [c setColor:[resourceDictionary objectForKey:@"car-color"]];
  NSNumber *numDoors = [resourceDictionary objectForKey:@"car-number-of-doors"];
  [c setNumDoors:[numDoors longValue]];
  return c;
}

@end
