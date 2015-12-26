//
//  TTDFUDeviceView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/5/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTChangeButtonView.h"

@interface TTDFUDeviceView : NSView {
    TTAppDelegate *appDelegate;
    TTDevice *device;

    NSDictionary *titleAttributes;
    CGSize textSize;
    TTChangeButtonView *changeButton;
    NSInteger latestVersion;
}

- (instancetype)initWithDevice:(TTDevice *)_device;

@end
