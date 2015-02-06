//
//  HCTestUtils.h
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

#import <Foundation/Foundation.h>
#import <Kiwi/Kiwi.h>
#import "HCRelation.h"

/**
 A collection of unit test-related helpers.
 */
@interface HCTestUtils : KWSpec

/**
 Convenience method for constructing HCRelation objects from strings; useful
 in unit test development.
 @param name the name for the relation instance
 @param subjectResMediaType the media type of the subject resource
 @param subjectResUri the URI of the subject resource
 @param targetResMediaType the media type of the target resource
 @param targetResUri the URI of the target resource
 @return initialized HCRelation instance
 */
+ (HCRelation *)relationWithName:(NSString *)name
        subjectResourceMediaType:(NSString *)subjectResMediaType
              subjectResourceUri:(NSString *)subjectResUri
         targetResourceMediaType:(NSString *)targetResMediaType
               targetResourceUri:(NSString *)targetResUri;

/**
 Runs a set of expectations ensuring the set of expected relations matches the
 given dictionary of actual relations.
 @param actualRels a dictionary of relations
 @param expectedRels an array of relations that should match-up and be
 equivalent to the given dictionary of relations
 */
+ (void)relations:(NSDictionary *)actualRels
shouldEqualRelations:(NSArray *)expectedRels;

@end
