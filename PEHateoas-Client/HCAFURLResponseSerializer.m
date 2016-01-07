//
//  HCAFURLResponseSerializer.m
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

#import "HCAFURLResponseSerializer.h"
#import "HCLogging.h"
#import "HCMediaType.h"
#import "HCResourceSerializer.h"

@implementation HCAFURLResponseSerializer {
  id<HCResourceSerializer> _hcserializer;
}

#pragma mark - Initializers

- (id)initWithHCSerializer:(id<HCResourceSerializer>)hcserializer {
  self = [super init];
  if (self) {
    _hcserializer = hcserializer;
  }
  return self;
}

#pragma mark - AFURLResponseSerialization protocol

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error {
  DDLogDebug(@"(HCAFURLResponseSerializer/responseObjectForResponse:) HTTP \
response: [%@].  Response body (assuming UTF-8 encoding): [%@].", response,
             [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
  NSString *contentTypeStr = [response MIMEType];
  HCMediaType *mediaType = nil;
  if (contentTypeStr) {
    mediaType = [HCMediaType MediaTypeFromString:contentTypeStr];
  }
  NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
  // don't try to parse 503 response because it'll be some default text/html
  // content from nginx or something meant for a human
  if (!(httpResp.statusCode == 503)) {
    return [_hcserializer deserializeResourceFromTextData:data
                                        resourceMediaType:mediaType
                                              resourceURL:[response URL]
                                             httpResponse:(NSHTTPURLResponse *)response];
  }
  return nil;
}

@end
