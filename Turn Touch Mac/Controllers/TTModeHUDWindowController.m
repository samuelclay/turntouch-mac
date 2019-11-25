//
//  TTHUDViewController.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTModeHUDWindowController.h"

@interface TTModeHUDWindowController ()

@property (nonatomic) BOOL isFading;

@end

@implementation TTModeHUDWindowController

- (instancetype)initWithWindowNibName:(NSString *)windowNibName {
    if (self = [super initWithWindowNibName:windowNibName]) {
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        [self.hudWindow setFrame:[self hiddenFrame] display:YES];
        [self showWindow:self.appDelegate];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.menuView setDelegate:self];
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
    [self.hudWindow makeKeyAndOrderFront:nil];
    [self.hudView setupTitleAttributes];
    self.hudView.isTeaser = NO;
    [self.hudView setNeedsDisplay:YES];
    [self.menuView.tableView reloadData];
    
    CGFloat alpha = 1.f;
    NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
    if (version.minorVersion <= 10) {
        alpha = 0.95f;
    }
    
    if (self.hudWindow.frame.origin.y != [self visibleFrame].origin.y) {
        [self.hudWindow setFrame:[self visibleFrame] display:YES];
    }
    if (!animate) {
        [[self.hudView gradientView] setAlphaValue:1.f];
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setCompletionHandler:^{

    }];
    [[NSAnimationContext currentContext] setDuration:.5f];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    [self.hudWindow setFrame:[self visibleFrame] display:YES];
    
    [[self.hudWindow animator] setAlphaValue:alpha];
    if (animate) {
        [self.hudView setNeedsDisplay:YES];
        [[[self.hudView gradientView] animator] setAlphaValue:1.f];
    }
    [NSAnimationContext endGrouping];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.menuView changeHighlightedRow:0];
    });
}

- (IBAction)fadeOut:(id)sender {
    //    __block __unsafe_unretained NSWindow *window = hudWindow;
    if (self.isFading) return;
    self.isFading = YES;

    [self.appDelegate.bluetoothMonitor.buttonTimer closeMenu];

    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.55f];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [self.hudWindow orderOut:nil];
        self.isFading = NO;
    }];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    [[self.hudWindow animator] setAlphaValue:0.f];
    [self.hudWindow setFrame:[self hiddenFrame] display:YES];
    
    [NSAnimationContext endGrouping];
}

- (void)teaseMode:(TTModeDirection)direction {
    self.hudView.isTeaser = YES;

    [self.hudWindow makeKeyAndOrderFront:nil];
    [self showWindow:self.appDelegate];
    [self.hudView setupTitleAttributes:[self.appDelegate.modeMap modeInDirection:direction]];
    [self.hudView setNeedsDisplay:YES];
    
    [[self.hudView gradientView] setAlphaValue:0.f];
    [[self.hudView teaserGradientView] setAlphaValue:1.f];

    if (self.hudWindow.frame.origin.y == [self hiddenFrame].origin.y) {
        [self.hudWindow setFrame:[self visibleFrame] display:YES];
        [[self.hudWindow animator] setAlphaValue:0.f];
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.4f];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];

    [[self.hudWindow animator] setAlphaValue:1.f];
    [self.hudWindow setFrame:[self visibleFrame] display:YES];

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
    
    for (NSString *action in self.appDelegate.modeMap.availableActions) {
        [options addObject:@{@"identifier" : action,
                             @"title"      : [self.appDelegate.modeMap.selectedMode titleForAction:action buttonMoment:BUTTON_MOMENT_PRESSDOWN],
                             @"icon"       : [self.appDelegate.modeMap.selectedMode imageNameForAction:action],
                             @"group"      : @"action",
                             }];
    }
    
    [options addObject:@{@"identifier": @"space"}];

    
    for (NSString *modeName in self.appDelegate.modeMap.availableModes) {
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
        [self.menuView menuUp];
    } else if (direction == EAST) {
        [self.menuView selectMenuItem];
    } else if (direction == WEST) {
        [self fadeOut:nil];
    } else if (direction == SOUTH) {
        [self.menuView menuDown];
    }
}

@end
