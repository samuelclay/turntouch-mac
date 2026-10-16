//
//  TTModeGoveeSwitchDevice.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTModeGovee.h"

@protocol TTModeGoveeSwitchDeviceDelegate <NSObject>
@required
- (BOOL)isSelected:(TTModeGoveeDevice *)device;
- (void)toggleDevice:(TTModeGoveeDevice *)device;
@end

@interface TTModeGoveeSwitchDevice : NSView

@property (nonatomic) IBOutlet NSTextField *nameLabel;
@property (nonatomic) IBOutlet NSTextField *selectedLabel;
@property (nonatomic) id<TTModeGoveeSwitchDeviceDelegate> delegate;

- (id)initWithDevice:(TTModeGoveeDevice *)device;
- (void)redraw;

@end
