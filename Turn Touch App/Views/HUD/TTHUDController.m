//
//  TTHUDController.m
//  Turn Touch App
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTHUDController.h"

@interface TTHUDController ()

@end

@implementation TTHUDController

@synthesize hudWindow;
@synthesize hudViewController;

- (instancetype)initWithWindowNibName:(NSString *)windowNibName {
    if (self = [super initWithWindowNibName:windowNibName]) {

    }
    return self;
}

- (void)awakeFromNib {
    appDelegate = (TTAppDelegate *)[NSApp delegate];
    
}

- (void)toastActiveMode {
    [self fadeIn:nil];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self fadeOut:nil];
    });
}

- (IBAction)fadeIn:(id)sender
{
    [hudWindow setAlphaValue:0.f];
    [hudWindow makeKeyAndOrderFront:nil];
    [self showWindow:appDelegate];
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.75f];
    [[hudWindow animator] setAlphaValue:1.f];
    [NSAnimationContext endGrouping];
}

- (IBAction)fadeOut:(id)sender
{
    [NSAnimationContext beginGrouping];
    __block __unsafe_unretained NSWindow *bself = hudWindow;
    [[NSAnimationContext currentContext] setDuration:.5f];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [bself orderOut:nil];
        [bself setAlphaValue:1.f];
    }];
    [[hudWindow animator] setAlphaValue:0.f];
    [NSAnimationContext endGrouping];
}

@end
