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
- (NSArray *)actions;

- (NSString *)defaultNorth;
- (NSString *)defaultEast;
- (NSString *)defaultWest;
- (NSString *)defaultSouth;

+ (NSString *)title;
+ (NSString *)description;
+ (NSString *)imageName;

@optional
- (void)activate;
- (void)deactivate;
- (NSArray *)optionlessActions;

@end
