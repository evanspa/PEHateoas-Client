//
//  HCTestUtils.m
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

#import "HCTestUtils.h"
#import "HCResource.h"
#import "HCMediaType.h"
#import <PEObjc-Commons/PEUtils.h>

@implementation HCTestUtils

+ (HCRelation *)relationWithName:(NSString *)name
        subjectResourceMediaType:(NSString *)subjectResMediaType
              subjectResourceUri:(NSString *)subjectResUri
         targetResourceMediaType:(NSString *)targetResMediaType
               targetResourceUri:(NSString *)targetResUri {
  return [[HCRelation alloc]
               initWithName:name
            subjectResource:
             [[HCResource alloc]
                   initWithMediaType:
                 [HCMediaType MediaTypeFromString:subjectResMediaType]
                                 uri:[NSURL URLWithString:subjectResUri]]
             targetResource:
             [[HCResource alloc]
                   initWithMediaType:
                 [HCMediaType MediaTypeFromString:targetResMediaType]
                                 uri:[NSURL URLWithString:targetResUri]]];
}

+ (void)relations:(NSDictionary *)actualRels
shouldEqualRelations:(NSArray *)expectedRels {
  [[theValue([actualRels count]) should] equal:theValue([expectedRels count])];
  NSDictionary *expectedRelationsDict =
    [PEUtils dictionaryFromArray:expectedRels
                   selectorAsKey:@selector(name)];
  [actualRels enumerateKeysAndObjectsUsingBlock:^(id actualRelationName,
                                                    id actualRelation,
                                                    BOOL *stop) {
    HCRelation *matchingExpectedRelation =
        [expectedRelationsDict objectForKey:actualRelationName];
    if (!matchingExpectedRelation) {
      @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"An \
'expected' relation for name: [%@] was not found", actualRelationName]
                                   userInfo:nil];
    }
    [matchingExpectedRelation shouldNotBeNil];
    [[actualRelation should] equal:matchingExpectedRelation];
    }];
}

@end
