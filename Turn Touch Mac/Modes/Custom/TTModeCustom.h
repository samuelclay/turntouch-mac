//
//  TTModeCustom.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 12/25/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTMode.h"

@interface TTModeCustom : TTMode

extern NSString *const kSingleCustomUrl;
extern NSString *const kDoubleCustomUrl;
extern NSString *const kSingleOutput;
extern NSString *const kDoubleOutput;
extern NSString *const kSingleHitCount;
extern NSString *const kDoubleHitCount;
extern NSString *const kSingleLastSuccess;
extern NSString *const kDoubleLastSuccess;

extern NSString *const kCustomFileUrl;
extern NSString *const kCustomScriptText;

- (void)runTTModeCustomURL:(TTModeDirection)direction;
- (void)doubleRunTTModeCustomURL:(TTModeDirection)direction;
- (void)runTTModeCustomScript:(TTModeDirection)direction;
- (void)doubleRunTTModeCustomScript:(TTModeDirection)direction;

@end
