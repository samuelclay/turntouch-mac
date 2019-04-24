//
//  TTDFUView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/4/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DFUOperations.h"
#import "TTAppDelegate.h"
#import "TTDevice.h"
#import "TTBorder.h"

@interface TTDeviceTitlesView : NSStackView <NSStackViewDelegate, DFUOperationsDelegate>

@property (nonatomic, weak) TTAppDelegate *appDelegate;

-(void)performDFU:(TTDevice *)device;

@end
