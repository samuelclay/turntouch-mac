//
//  TTModeProtocol.h
//  Turn Touch App
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TTModeProtocol <NSObject>

@required
- (void)runNorth;
- (void)runEast;
- (void)runWest;
- (void)runSouth;

- (NSString *)imageName;
- (NSString *)titleNorth;
- (NSString *)titleEast;
- (NSString *)titleWest;
- (NSString *)titleSouth;
+ (NSString *)title;
+ (NSString *)description;

@optional
- (void)activate;
- (void)deactivate;

@end
