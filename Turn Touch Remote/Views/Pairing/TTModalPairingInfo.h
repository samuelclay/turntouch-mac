//
//  TTModalPairingInfo.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/10/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTPanelStates.h"

@interface TTModalPairingInfo : NSView

@property (nonatomic) IBOutlet NSTextField *titleLabel;
@property (nonatomic) IBOutlet NSTextField *subtitleLabel;
@property (nonatomic) IBOutlet NSImageView *heroImage;

- (instancetype)initWithPairing:(TTModalPairing)modalPairing;

@end
