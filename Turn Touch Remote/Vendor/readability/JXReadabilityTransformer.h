//
//  JXReadabilityTransformer.h
//  readability
//
//  Created by Matias Piipari on 03/10/2014.
//  Copyright (c) 2014 geheimwerk.de. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>


@interface JXReadabilityTransformer : NSObject

- (WebArchive *)readableWebArchiveForContentsOfURL:(NSURL *)URL
                                 preprocessHandler:(NSData *(^)(NSData *data, NSError **preprocessError))preprocessHandler
                                             error:(NSError **)error;

- (WebArchive *)readableWebArchiveForWebArchive:(WebArchive *)webarchive
                              preprocessHandler:(NSData *(^)(NSData *data, NSError **preprocessError))preprocessHandler
                                          error:(NSError **)error;

@end
