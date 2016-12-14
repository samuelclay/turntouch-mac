//
//  TTHUDViewController.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTModeHUDWindowController.h"

@implementation TTModeHUDWindowController

@synthesize hudView;
@synthesize hudWindow;
@synthesize menuView;

- (instancetype)initWithWindowNibName:(NSString *)windowNibName {
    if (self = [super initWithWindowNibName:windowNibName]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        [hudWindow setFrame:[self hiddenFrame] display:YES];
        [self showWindow:appDelegate];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [menuView setDelegate:self];
}

#pragma mark - Window management

- (NSRect)visibleFrame {
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
    
    return NSMakeRect(0, 0, NSWidth(mainScreen.frame), NSHeight(mainScreen.frame));
}

- (NSRect)hiddenFrame {
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
    
    return NSMakeRect(0, 0, NSWidth(mainScreen.frame), NSHeight(mainScreen.frame));
}

- (void)fadeIn:(BOOL)animate {
    [hudWindow makeKeyAndOrderFront:nil];
    [hudView setupTitleAttributes];
    hudView.isTeaser = NO;
    [hudView setNeedsDisplay:YES];
    [menuView.tableView reloadData];
    
    CGFloat alpha = 1.f;
    NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
    if (version.minorVersion <= 10) {
        alpha = 0.95f;
    }
    
    if (hudWindow.frame.origin.y != [self visibleFrame].origin.y) {
        [hudWindow setFrame:[self visibleFrame] display:YES];
    }
    if (!animate) {
        [[hudView gradientView] setAlphaValue:1.f];
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setCompletionHandler:^{

    }];
    [[NSAnimationContext currentContext] setDuration:.5f];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    [hudWindow setFrame:[self visibleFrame] display:YES];
    
    [[hudWindow animator] setAlphaValue:alpha];
    if (animate) {
        [hudView setNeedsDisplay:YES];
        [[[hudView gradientView] animator] setAlphaValue:1.f];
    }
    [NSAnimationContext endGrouping];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [menuView changeHighlightedRow:0];
    });
}

- (IBAction)fadeOut:(id)sender {
    //    __block __unsafe_unretained NSWindow *window = hudWindow;
    if (isFading) return;
    isFading = YES;

    [appDelegate.bluetoothMonitor.buttonTimer closeMenu];

    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.55f];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
//        [hudWindow orderOut:nil];
        isFading = NO;
    }];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    [[hudWindow animator] setAlphaValue:0.f];
    [hudWindow setFrame:[self hiddenFrame] display:YES];
    
    [NSAnimationContext endGrouping];
}

- (void)teaseMode:(TTModeDirection)direction {
    hudView.isTeaser = YES;

    [hudWindow makeKeyAndOrderFront:nil];
    [self showWindow:appDelegate];
    [hudView setupTitleAttributes:[appDelegate.modeMap modeInDirection:direction]];
    [hudView setNeedsDisplay:YES];
    
    [[hudView gradientView] setAlphaValue:0.f];
    [[hudView teaserGradientView] setAlphaValue:1.f];

    if (hudWindow.frame.origin.y == [self hiddenFrame].origin.y) {
        [hudWindow setFrame:[self visibleFrame] display:YES];
        [[hudWindow animator] setAlphaValue:0.f];
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.4f];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];

    [[hudWindow animator] setAlphaValue:1.f];
    [hudWindow setFrame:[self visibleFrame] display:YES];

    [NSAnimationContext endGrouping];
}

#pragma mark - HUD Menu Delegate

- (NSInteger)menuInitialPosition {
    return -200;
}

- (NSArray *)menuOptions {
    NSMutableArray *options = [NSMutableArray array];
    [options addObject:@{@"identifier": @"space"}];
    [options addObject:@{@"identifier": @"close",
                         @"title"       : @"Close"}];
    [options addObject:@{@"identifier": @"space"}];
    
    for (NSString *action in appDelegate.modeMap.availableActions) {
        [options addObject:@{@"identifier" : action,
                             @"title"      : [appDelegate.modeMap.selectedMode titleForAction:action buttonMoment:BUTTON_MOMENT_PRESSDOWN],
                             @"icon"       : [appDelegate.modeMap.selectedMode imageNameForAction:action],
                             @"group"      : @"action",
                             }];
    }
    
    [options addObject:@{@"identifier": @"space"}];

    
    for (NSString *modeName in appDelegate.modeMap.availableModes) {
        Class modeClass = NSClassFromString(modeName);
        [options addObject:@{@"identifier" : modeName,
                             @"title"      : [modeClass title],
                             @"icon"       : [modeClass imageName],
                             @"group"      : @"mode",
                             }];
    }

    return options;
}

- (void)runDirection:(TTModeDirection)direction {
    if (direction == NORTH) {
        [menuView menuUp];
    } else if (direction == EAST) {
        [menuView selectMenuItem];
    } else if (direction == WEST) {
        [self fadeOut:nil];
    } else if (direction == SOUTH) {
        [menuView menuDown];
    }
}

@end
