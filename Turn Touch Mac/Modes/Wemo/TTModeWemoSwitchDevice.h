//
//  TTModeWemoSwitchDevice.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/21/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTModeWemo.h"

@protocol TTModeWemoSwitchDeviceDelegate <NSObject>
@required
- (BOOL)isSelected:(TTModeWemoDevice *)device;
- (void)toggleDevice:(TTModeWemoDevice *)device;
@end

@interface TTModeWemoSwitchDevice : NSView {
    TTModeWemoDevice *device;
    NSTrackingArea *trackingArea;
}

@property (nonatomic) IBOutlet NSTextField *nameLabel;
@property (nonatomic) IBOutlet NSTextField *selectedLabel;
@property (nonatomic) id<TTModeWemoSwitchDeviceDelegate> delegate;

- (id)initWithDevice:(TTModeWemoDevice *)_device;
- (void)redraw;

@end
