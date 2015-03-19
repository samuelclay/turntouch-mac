//
//  TTModeProtocol.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TTModeProtocol <NSObject>

@required
- (NSArray *)actions;

- (NSString *)defaultNorth;
- (NSString *)defaultEast;
- (NSString *)defaultWest;
- (NSString *)defaultSouth;
- (NSString *)defaultInfo;

+ (NSString *)title;
+ (NSString *)description;
+ (NSString *)imageName;

@optional
- (void)activate;
- (void)activate:(TTModeDirection)modeDirection;
- (void)activateTimers;
- (void)deactivate;
- (NSArray *)optionlessActions;

@end
