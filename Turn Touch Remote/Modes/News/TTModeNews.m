//
//  TTModeNews.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/8/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeNews.h"
#import <WebKit/WebKit.h>
#import "Safari.h"
#import <IOKit/pwr_mgt/IOPMLib.h>
#import <Webkit/Webkit.h>
#import <WebKit/WebArchive.h>

#import "KBWebArchiver.h"
#import "JXReadabilityDocument.h"
#import "JXWebResourceLoadingBarrier.h"

@implementation TTModeNews

@synthesize newsblur;

#pragma mark - Mode

- (instancetype)init {
    if (self = [super init]) {
        newsblur = [[TTModeNewsNewsBlur alloc] init];
    }
    
    return self;
}

+ (NSString *)title {
    return @"NewsBlur";
}

+ (NSString *)description {
    return @"The news from NewsBlur";
}

+ (NSString *)imageName {
    return @"mode_news.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeNewsNextStory",
             @"TTModeNewsNextSite",
             @"TTModeNewsPreviousStory",
             @"TTModeNewsPreviousSite",
             @"TTModeNewsScrollUp",
             @"TTModeNewsScrollDown",
             @"TTModeNewsMenu",
             ];
}

- (NSArray *)menuOptions {
    return @[@{@"identifier" : @"space"},
             @{@"identifier" : @"TTModeNewsMenuReturn",
               @"title"      : @"Return",
               @"icon"       : @"double_tap",
               @"group"      : @"action",
               },
             @{@"identifier" : @"space"},
             @{@"identifier" : @"TTModeNewsNextStory",
               @"title"      : @"Next story",
               @"icon"       : @"heart",
               @"group"      : @"action",
               },
             @{@"identifier" : @"TTModeNewsPreviousStory",
               @"title"      : @"Previous story",
               @"icon"       : @"cog",
               @"group"      : @"action",
               },
             @{@"identifier" : @"space"},
             @{@"identifier" : @"TTModeNewsMenuFontSizeUp",
               @"title"      : @"Larger text",
               @"icon"       : @"button_chevron",
               @"group"      : @"action",
               },
             @{@"identifier" : @"TTModeNewsMenuFontSizeDown",
               @"title"      : @"Smaller text",
               @"icon"       : @"button_dash",
               @"group"      : @"action",
               },
             @{@"identifier" : @"space"},
             @{@"identifier" : @"TTModeNewsMenuWider",
               @"title"      : @"Widen story",
               @"icon"       : @"arrow",
               @"group"      : @"action",
               },
             @{@"identifier" : @"TTModeNewsMenuNarrower",
               @"title"      : @"Narrow story",
               @"icon"       : @"arrow",
               @"group"      : @"action",
               },
             @{@"identifier" : @"space"},
             @{@"identifier" : @"TTModeNewsMenuClose",
               @"title"      : @"Close NewsBlur",
               @"icon"       : @"button_x",
               @"group"      : @"action",
               },
             ];
}

#pragma mark - Action Titles

- (NSString *)actionTitleInDirection:(TTModeDirection)direction buttonMoment:(TTButtonMoment)buttonMoment {
    if (state == TTModeNewsStateMenu) {
        switch (direction) {
            case EAST:
                return [newsWindowController.menuView highlightedRowTitle];
            default:
                break;
        }
    }
    
    return [super actionTitleInDirection:direction buttonMoment:buttonMoment];
}

- (NSString *)titleTTModeNewsMenu {
    return @"Menu";
}
- (NSString *)titleTTModeNewsNextStory {
    return @"Next story";
}
- (NSString *)titleTTModeNewsNextSite {
    return @"Next site";
}
- (NSString *)titleTTModeNewsPreviousStory {
    return @"Previous story";
}
- (NSString *)titleTTModeNewsPreviousSite {
    return @"Previous site";
}
- (NSString *)titleTTModeNewsScrollUp {
    return @"Scroll up";
}
- (NSString *)titleTTModeNewsScrollDown {
    return @"Scroll down";
}

#pragma mark - Action Images

- (NSString *)imageTTModeNewsMenu {
    return @"web_menu.png";
}
- (NSString *)imageTTModeNewsNextStory {
    return @"next_story.png";
}
- (NSString *)imageTTModeNewsNextSite {
    return @"next_site.png";
}
- (NSString *)imageTTModeNewsPreviousStory {
    return @"previous_story.png";
}
- (NSString *)imageTTModeNewsPreviousSite {
    return @"previous_site.png";
}
- (NSString *)imageTTModeNewsScrollUp {
    return @"scroll_up.png";
}
- (NSString *)imageTTModeNewsScrollDown {
    return @"scroll_down.png";
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeNewsScrollUp";
}
- (NSString *)defaultEast {
    return @"TTModeNewsNextSite";
}
- (NSString *)defaultWest {
    return @"TTModeNewsMenu";
}
- (NSString *)defaultSouth {
    return @"TTModeNewsScrollDown";
}

#pragma mark - Immediate Fire on Press

- (BOOL)shouldFireImmediateTTModeNewsScrollUp {
    return YES;
}

- (BOOL)shouldFireImmediateTTModeNewsScrollDown {
    return YES;
}

- (BOOL)shouldFireImmediateTTModeNewsMenuUp {
    return YES;
}

- (BOOL)shouldFireImmediateTTModeNewsMenuDown {
    return YES;
}

#pragma mark - Hide HUD

- (BOOL)shouldHideHudTTModeNewsScrollUp {
    return YES;
}

- (BOOL)shouldHideHudTTModeNewsScrollDown {
    return YES;
}

- (BOOL)shouldHideHudTTModeNewsNextStory {
    return YES;
}

- (BOOL)shouldHideHudTTModeNewsMenu {
    return YES;
}

- (BOOL)shouldHideHudTTModeNewsMenuReturn {
    return YES;
}

- (BOOL)shouldHideHudTTModeNewsMenuUp {
    return YES;
}

- (BOOL)shouldHideHudTTModeNewsMenuDown {
    return YES;
}

- (BOOL)shouldHideHudTTModeNewsMenuSelect {
    if (state == TTModeNewsStateMenu) {
        return NO;
    }
    
    return NO;
}

#pragma mark - Action methods

- (BOOL)checkClosed {
    if (closed) {
        closed = NO;
        [self loadStories];
        [self startHideMouseTimer];
        [self setDisplayAwake:YES];
        
        return YES;
    }
    
    return NO;
}

- (void)startHideMouseTimer {
    if (timerActive) return;
    [NSCursor unhide];
    timerActive = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        timerActive = NO;
        CFTimeInterval secondsSinceMouseMove = CGEventSourceSecondsSinceLastEventType(kCGEventSourceStateCombinedSessionState, kCGEventMouseMoved);
        if (secondsSinceMouseMove > 2.5) {
            [NSCursor hide];
        } else {
            [self startHideMouseTimer];
        }
    });
}

- (void)setDisplayAwake:(BOOL)forceAwake {
    // kIOPMAssertionTypeNoDisplaySleep prevents display sleep,
    // kIOPMAssertionTypeNoIdleSleep prevents idle sleep
    
    //reasonForActivity is a descriptive string used by the system whenever it needs
    //  to tell the user why the system is not sleeping. For example,
    //  "Mail Compacting Mailboxes" would be a useful string.
    
    //  NOTE: IOPMAssertionCreateWithName limits the string to 128 characters.
    CFStringRef reasonForActivity= CFSTR("Turn Touch Reader");
    
    IOPMAssertionID assertionID;
    IOReturn success = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep,
                                                   forceAwake ? kIOPMAssertionLevelOn : kIOPMAssertionLevelOff, reasonForActivity, &assertionID);
    if (success == kIOReturnSuccess)
    {
        
        //Add the work you need to do without
        //  the system sleeping here.
        
        success = IOPMAssertionRelease(assertionID);
        //The system will be able to sleep again.
    }
}

- (void)runTTModeNewsMenu {
    if ([self checkClosed]) return;
    
    if (state == TTModeNewsStateBrowser) {
        state = TTModeNewsStateMenu;
        [newsWindowController.menuView slideIn];
    } else if (state == TTModeNewsStateMenu) {
        state = TTModeNewsStateBrowser;
        [newsWindowController.menuView slideOut];
    }
}

- (void)doubleRunTTModeNewsMenu {
    [self doubleRunTTModeNewsMenuReturnBack];
}

- (void)doubleRunTTModeNewsMenuReturn {
    [self doubleRunTTModeNewsMenuReturnBack];
}

- (void)doubleRunTTModeNewsMenuReturnBack {
    if ([self checkClosed]) return;
    
    [self runTTModeNewsPreviousStory];
    if (state == TTModeNewsStateMenu) {
        state = TTModeNewsStateBrowser;
        [newsWindowController.menuView slideOut];
    }
}

- (void)runTTModeNewsNext {
    if ([self checkClosed]) return;
    
    if (state == TTModeNewsStateBrowser) {
        
    } else if (state == TTModeNewsStateMenu) {
        [newsWindowController.menuView selectMenuItem];
    }
}
- (void)runTTModeNewsScrollUp {
    if ([self checkClosed]) return;
    
    [newsWindowController.browserView scrollUp];
    [NSCursor hide];
}
- (void)runTTModeNewsScrollDown {
    if ([self checkClosed]) return;
    
    [newsWindowController.browserView scrollDown];
    [NSCursor hide];
}

- (void)runTTModeNewsNextStory {
    if ([self checkClosed]) return;
    
    NSLog(@"Running TTModeNewsNextStory");
    [newsWindowController.browserView nextStory];
}
- (void)runTTModeNewsNextSite {
    if ([self checkClosed]) return;
    
    NSLog(@"Running TTModeNewsNextSite");
}
- (void)runTTModeNewsPreviousStory {
    if ([self checkClosed]) return;
    
    NSLog(@"Running TTModeNewsPreviousStory");
    [newsWindowController.browserView previousStory];
}
- (void)runTTModeNewsPreviousSite {
    if ([self checkClosed]) return;
    
    NSLog(@"Running TTModeNewsPreviousSite");
}
- (void)runTTModeNewsMenuFontSizeUp {
    [newsWindowController.browserView zoomIn];
}

- (void)runTTModeNewsMenuFontSizeDown {
    [newsWindowController.browserView zoomOut];
}

- (void)runTTModeNewsMenuWider {
    [newsWindowController.browserView widenStory];
}

- (void)runTTModeNewsMenuNarrower {
    [newsWindowController.browserView narrowStory];
}


#pragma mark - News

- (void)activate {
    closed = YES;
    state = TTModeNewsStateBrowser;
    
    newsWindowController = [[TTModeNewsWindowController alloc] initWithWindowNibName:@"TTModeNewsWindowController"];
}

- (void)deactivate {
    [newsWindowController fadeOut];
    [self setDisplayAwake:NO];
    [NSCursor unhide];
}

- (void)loadStories {
    [newsWindowController fadeIn];
    [newsblur fetchRiverStories:^(NSArray *stories) {
        [newsWindowController addStories:stories];
    }];
    
//    [newsWindowController.browserView ];
}

#pragma mark - Menu Options

- (NSString *)actionNameInDirection:(TTModeDirection)direction {
    if (state == TTModeNewsStateMenu) {
        switch (direction) {
            case NORTH:
                return @"TTModeNewsMenuUp";
            case EAST:
                return @"TTModeNewsMenuSelect";
            case WEST:
                return @"TTModeNewsMenuReturn";
            case SOUTH:
                return @"TTModeNewsMenuDown";
            default:
                break;
        }
    }
    
    return [super actionNameInDirection:direction];
}

- (void)runTTModeNewsMenuReturn {
    state = TTModeNewsStateBrowser;
    [newsWindowController.menuView slideOut];
}
- (void)runTTModeNewsMenuUp {
    [newsWindowController.menuView menuUp];
}
- (void)runTTModeNewsMenuDown {
    [newsWindowController.menuView menuDown];
}
- (void)runTTModeNewsMenuSelect {
    [newsWindowController.menuView selectMenuItem];
}

- (void)runTTModeNewsMenuClose {
    if (!closed) {
        closed = YES;
        [self setDisplayAwake:NO];
        [NSCursor unhide];
        [newsWindowController fadeOut];
        state = TTModeNewsStateBrowser;
        [newsWindowController.menuView slideOut];
    }
}

@end
