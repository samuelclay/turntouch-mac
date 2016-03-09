//
//  TTModeWeb.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/29/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTModeWeb.h"
#import <WebKit/WebKit.h>
#import "Safari.h"
#import <IOKit/pwr_mgt/IOPMLib.h>
#import <Webkit/Webkit.h>
#import <WebKit/WebArchive.h>

#import "KBWebArchiver.h"
#import "JXReadabilityDocument.h"
#import "JXWebResourceLoadingBarrier.h"

@implementation TTModeWeb

#pragma mark - Mode

+ (NSString *)title {
    return @"Web";
}

+ (NSString *)description {
    return @"Read the web on your Mac";
}

+ (NSString *)imageName {
    return @"mode_web.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeWebMenu",
             @"TTModeWebNext",
             @"TTModeWebScrollUp",
             @"TTModeWebScrollDown",
             ];
}

- (NSArray *)menuOptions {
    return @[@{@"identifier" : @"space"},
             @{@"identifier" : @"TTModeWebMenuReturn",
               @"title"      : @"Return",
               @"icon"       : @"double_tap",
               @"group"      : @"action",
               },
             @{@"identifier" : @"space"},
             @{@"identifier" : @"TTModeWebMenuNextStory",
               @"title"      : @"Next story",
               @"icon"       : @"heart",
               @"group"      : @"action",
               },
             @{@"identifier" : @"TTModeWebMenuPreviousStory",
               @"title"      : @"Previous story",
               @"icon"       : @"cog",
               @"group"      : @"action",
               },
             @{@"identifier" : @"space"},
             @{@"identifier" : @"TTModeWebMenuFontSizeUp",
               @"title"      : @"Larger text",
               @"icon"       : @"button_chevron",
               @"group"      : @"action",
               },
             @{@"identifier" : @"TTModeWebMenuFontSizeDown",
               @"title"      : @"Smaller text",
               @"icon"       : @"button_dash",
               @"group"      : @"action",
               },
             @{@"identifier" : @"space"},
             @{@"identifier" : @"TTModeWebMenuMarginWider",
               @"title"      : @"Widen margin",
               @"icon"       : @"arrow",
               @"group"      : @"action",
               },
             @{@"identifier" : @"TTModeWebMenuMarginNarrower",
               @"title"      : @"Narrow margin",
               @"icon"       : @"arrow",
               @"group"      : @"action",
               },
             @{@"identifier" : @"space"},
             @{@"identifier" : @"TTModeWebMenuClose",
               @"title"      : @"Close Reader",
               @"icon"       : @"button_x",
               @"group"      : @"action",
               },
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeWebMenu {
    return @"Menu";
}
- (NSString *)titleTTModeWebNext {
    return @"OK / Next";
}
- (NSString *)titleTTModeWebScrollUp {
    return @"Scroll up";
}
- (NSString *)titleTTModeWebScrollDown {
    return @"Scroll down";
}

#pragma mark - Action Images

- (NSString *)imageTTModeWebMenu {
    return @"next_story.png";
}
- (NSString *)imageTTModeWebNext {
    return @"next_site.png";
}
- (NSString *)imageTTModeWebScrollUp {
    return @"previous_story.png";
}
- (NSString *)imageTTModeWebScrollDown {
    return @"previous_site.png";
}

#pragma mark - Immediate Fire on Press

- (BOOL)shouldFireImmediateTTModeWebScrollUp {
    return YES;
}

- (BOOL)shouldFireImmediateTTModeWebScrollDown {
    return YES;
}

#pragma mark - Hide HUD

- (BOOL)shouldHideHudTTModeWebScrollUp {
    return YES;
}

- (BOOL)shouldHideHudTTModeWebScrollDown {
    return YES;
}

#pragma mark - Action methods

- (BOOL)checkClosed {
    if (closed) {
        closed = NO;
        [self loadSafari];
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

- (void)runTTModeWebMenu {
    if ([self checkClosed]) return;
    
    if (state == TTModeWebStateBrowser) {
        state = TTModeWebStateMenu;
        [webWindowController.menuView slideIn];
    } else if (state == TTModeWebStateMenu) {
        state = TTModeWebStateBrowser;
        [webWindowController.menuView slideOut];
    }
}
- (void)runTTModeWebNext {
    if ([self checkClosed]) return;
    
    if (state == TTModeWebStateBrowser) {

    } else if (state == TTModeWebStateMenu) {
        [webWindowController.menuView selectMenuItem];
    }
}
- (void)runTTModeWebScrollUp {
    if ([self checkClosed]) return;
    
    if (state == TTModeWebStateBrowser) {
        [webWindowController.browserView scrollUp];
        [NSCursor hide];
    } else if (state == TTModeWebStateMenu) {
        [webWindowController.menuView menuUp];
    }
}
- (void)runTTModeWebScrollDown {
    if ([self checkClosed]) return;
    
    if (state == TTModeWebStateBrowser) {
        [webWindowController.browserView scrollDown];
        [NSCursor hide];
    } else if (state == TTModeWebStateMenu) {
        [webWindowController.menuView menuDown];
    }
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeWebScrollUp";
}
- (NSString *)defaultEast {
    return @"TTModeWebNext";
}
- (NSString *)defaultWest {
    return @"TTModeWebMenu";
}
- (NSString *)defaultSouth {
    return @"TTModeWebScrollDown";
}

#pragma mark - Web

- (void)activate {
    closed = YES;
    state = TTModeWebStateBrowser;
    
    webWindowController = [[TTModeWebWindowController alloc] initWithWindowNibName:@"TTModeWebWindowController"];
}

- (void)deactivate {
    [webWindowController fadeOut];
    [self setDisplayAwake:NO];
    [NSCursor unhide];
}

- (void)loadSafari {
    [webWindowController fadeIn];

    SafariApplication *safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
    
    SBElementArray* windows = [safari windows];
    SafariWindow *safariWindow = [windows objectAtIndex:0];
    // This fails when in full-screen mode:
    SafariTab* currentTab = [safariWindow currentTab];
    
    // https://medium.com/the-development-set/the-reductive-seduction-of-other-people-s-problems-3c07b307732d
    [webWindowController.browserView loadURL:currentTab.URL html:[self readabilityForUrl:currentTab.URL htmlSource:nil] title:currentTab.name];
}

#pragma mark - Menu Options

- (void)runTTModeWebMenuReturn {
    state = TTModeWebStateBrowser;
    [webWindowController.menuView slideOut];
}

- (void)runTTModeWebMenuNextStory {
    
}

- (void)runTTModeWebMenuPreviousStory {
    [webWindowController.browserView.webView goBack];
}

- (void)runTTModeWebMenuFontSizeUp {
    [webWindowController.browserView zoomIn];
}

- (void)runTTModeWebMenuFontSizeDown {
    [webWindowController.browserView zoomOut];
}

- (void)runTTModeWebMenuMarginWider {
    [webWindowController.browserView widenMargin];
}

- (void)runTTModeWebMenuMarginNarrower {
    [webWindowController.browserView narrowMargin];
}

- (void)runTTModeWebMenuClose {
    if (!closed) {
        closed = YES;
        [self setDisplayAwake:NO];
        [NSCursor unhide];
        [webWindowController fadeOut];
        state = TTModeWebStateBrowser;
        [webWindowController.menuView slideOut];
    }
}

#pragma mark - Readability

- (NSString *)readabilityForUrl:(NSString *)urlString htmlSource:(NSString *)htmlSource {
    NSError *error = nil;
    WebArchive *webarchive;
    KBWebArchiver *archiver = [[KBWebArchiver alloc] initWithURLString:urlString];
    archiver.localResourceLoadingOnly = htmlSource && htmlSource.length;
    webarchive = [archiver webArchive];
    [webarchive data];
    error = [archiver error];
    
    WebResource *resource = [webarchive mainResource];
    
    NSString *textEncodingName = [resource textEncodingName];
    
    NSStringEncoding encoding;
    if (textEncodingName == nil) {
        encoding = NSISOLatin1StringEncoding;
    }
    else {
        CFStringEncoding cfEnc = CFStringConvertIANACharSetNameToEncoding((CFStringRef)textEncodingName);
        if (kCFStringEncodingInvalidId == cfEnc) {
            encoding = NSUTF8StringEncoding;
        }
        else {
            encoding = CFStringConvertEncodingToNSStringEncoding(cfEnc);
        }
    }
    
    NSString *source = [[NSString alloc] initWithData:[resource data]
                                             encoding:encoding];
    NSXMLDocumentContentKind contentKind = NSXMLDocumentXHTMLKind;
    NSUInteger xmlOutputOptions = (contentKind
                                   | NSXMLNodePrettyPrint
                                   | NSXMLNodePreserveWhitespace
                                   | NSXMLNodeCompactEmptyElement
                                   );
    
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithXMLString:source
                                                          options:NSXMLDocumentTidyHTML
                                                            error:&error];
    NSXMLDocument *cleanedDoc = nil;
    NSXMLDocument *summaryDoc = nil;
    
    if (doc != nil) {
        [doc setDocumentContentKind:contentKind];
        
        {
            JXReadabilityDocument *readabilityDoc = [[JXReadabilityDocument alloc] initWithXMLDocument:doc
                                                                                          copyDocument:NO];
            summaryDoc = [readabilityDoc summaryXMLDocument];
            cleanedDoc = readabilityDoc.html;
            
            NSLog(@"\nTitle: %@", readabilityDoc.title);
            NSLog(@"\nShort Title: %@", readabilityDoc.shortTitle);
            
        }
    }
    
    // Create a new webarchive with the processed markup as main content and the resources from the source webarchive
    NSData *docData = [summaryDoc XMLDataWithOptions:xmlOutputOptions];
    return [[NSString alloc] initWithData:docData encoding:NSUTF8StringEncoding];
    
}

@end
