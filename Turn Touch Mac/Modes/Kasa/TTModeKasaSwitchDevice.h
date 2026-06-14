//
//  TTModeKasaSwitchDevice.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTModeKasa.h"

@protocol TTModeKasaSwitchDeviceDelegate <NSObject>
@required
- (BOOL)isSelected:(TTModeKasaDevice *)device;
- (void)toggleDevice:(TTModeKasaDevice *)device;
@end

@interface TTModeKasaSwitchDevice : NSView

@property (nonatomic) IBOutlet NSTextField *nameLabel;
@property (nonatomic) IBOutlet NSTextField *selectedLabel;
@property (nonatomic) id<TTModeKasaSwitchDeviceDelegate> delegate;

- (id)initWithDevice:(TTModeKasaDevice *)device;
- (void)redraw;

@end
