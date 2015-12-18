//
//  HCRelation.m
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

#import "HCRelation.h"
#import "HCResource.h"

@implementation HCRelation {
  NSString *_name;
  HCResource *_subject;
  HCResource *_target;
}

#pragma mark - Initializers

- (id)initWithName:(NSString *)name
   subjectResource:(HCResource *)subject
    targetResource:(HCResource *)target {
  self = [super init];
  if (self) {
    _name = name;
    _subject = subject;
    _target = target;
  }
  return self;
}

#pragma mark - Equality

- (BOOL)isEqualToRelation:(HCRelation *)relation {
  if (!relation) {
    return NO;
  }
  BOOL haveEqualNames = [[self name] isEqualToString:[relation name]];
  BOOL haveEqualSubjects = [[self subject] isEqualToResource:[relation subject]];
  BOOL haveEqualTargets = [[self target] isEqualToResource:[relation target]];
  return haveEqualNames && haveEqualSubjects && haveEqualTargets;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
  if (self == object) {
    return YES;
  }
  if (![object isKindOfClass:[HCRelation class]]) {
    return NO;
  }
  return [self isEqualToRelation:(HCRelation *)object];
}

- (NSUInteger)hash {
  return [[self name] hash] ^ [[self subject] hash] ^ [[self target] hash];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"name: [%@], subject resource: [%@], \
target resource: [%@]", _name, _subject, _target];
}

@end
