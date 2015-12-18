//
//  HCRelation.h
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
@class HCResource;

/**
 An abstraction for modeling a hyperlink relation.  A link relation
 has a name, and relates 2 resources together (dubbed 'subject' and
 'target' by this abstraction).
 */
@interface HCRelation : NSObject

#pragma mark - Initializers

/**
 Creates and returns a new relation with the given name, and relates the given
 resources.
 @param name the name of the relation
 @param subject the subject resource
 @param target the target resource
 */
- (id)initWithName:(NSString *)name
   subjectResource:(HCResource *)subject
    targetResource:(HCResource *)target;

#pragma mark - Equality

/**
 @param relation the relation with which to compare the receiving relation
 @return a Boolean value that indicates whether the receiving relation is
 equal to the given relation.
*/
- (BOOL)isEqualToRelation:(HCRelation *)relation;

#pragma mark - Properties

/**
 The name of the relation.
 */
@property (nonatomic, readonly) NSString *name;

/**
 The subject resource of the relation.
 */
@property (nonatomic, readonly) HCResource *subject;

/**
 The target resource of the relation.
 */
@property (nonatomic, readonly) HCResource *target;

@end
