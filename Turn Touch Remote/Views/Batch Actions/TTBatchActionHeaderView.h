//
//  TTBatchActionHeaderView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/20/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TTBatchActionHeaderView : NSView

@property (nonatomic) NSString *modeName;

- (instancetype)initWithMode:(NSString *)_modeName;

@end
