//
//  SonosPlayableItem.m
//  
//
//  Created by Rob Howard on 12/6/15.
//
//

#import "SonosPlayable.h"

@implementation SonosPlayable

- (NSString *)resTextEscaped{
  return [self escapeXMLString:self.resText];
}

- (NSString *)resMDEscaped{
  return [self escapeXMLString:self.resMD];
}

- (NSString *)escapeXMLString:(NSString *)string{
  NSMutableString *escapedXMLString = [[NSMutableString alloc] initWithString:string];
  
  [escapedXMLString replaceOccurrencesOfString:@"&"  withString:@"&amp;"  options:NSLiteralSearch range:NSMakeRange(0, [escapedXMLString length])];
  [escapedXMLString replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, [escapedXMLString length])];
  [escapedXMLString replaceOccurrencesOfString:@"'"  withString:@"&#x27;" options:NSLiteralSearch range:NSMakeRange(0, [escapedXMLString length])];
  [escapedXMLString replaceOccurrencesOfString:@">"  withString:@"&gt;"   options:NSLiteralSearch range:NSMakeRange(0, [escapedXMLString length])];
  [escapedXMLString replaceOccurrencesOfString:@"<"  withString:@"&lt;"   options:NSLiteralSearch range:NSMakeRange(0, [escapedXMLString length])];
  
  return escapedXMLString;
}

- (NSString *)description{
  return [NSString stringWithFormat:@"<SonosPlayable: %p, title: %@ >",
          self, self.title];
}

@end
