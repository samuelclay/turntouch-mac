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

#pragma mark - Mode

+ (NSString *)title {
    return @"News";
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

#pragma mark - Hide HUD

- (BOOL)shouldHideHudTTModeNewsScrollUp {
    return YES;
}

- (BOOL)shouldHideHudTTModeNewsScrollDown {
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
- (void)runTTModeNewsNext {
    if ([self checkClosed]) return;
    
    if (state == TTModeNewsStateBrowser) {
        
    } else if (state == TTModeNewsStateMenu) {
        [newsWindowController.menuView selectMenuItem];
    }
}
- (void)runTTModeNewsScrollUp {
    if ([self checkClosed]) return;
    
    if (state == TTModeNewsStateBrowser) {
        [newsWindowController.browserView scrollUp];
        [NSCursor hide];
    } else if (state == TTModeNewsStateMenu) {
        [newsWindowController.menuView menuUp];
    }
}
- (void)runTTModeNewsScrollDown {
    if ([self checkClosed]) return;
    
    if (state == TTModeNewsStateBrowser) {
        [newsWindowController.browserView scrollDown];
        [NSCursor hide];
    } else if (state == TTModeNewsStateMenu) {
        [newsWindowController.menuView menuDown];
    }
}

- (void)runTTModeNewsNextStory {
    NSLog(@"Running TTModeNewsNextStory");
}
- (void)runTTModeNewsNextSite {
    NSLog(@"Running TTModeNewsNextSite");
}
- (void)runTTModeNewsPreviousStory {
    NSLog(@"Running TTModeNewsPreviousStory");
}
- (void)runTTModeNewsPreviousSite {
    NSLog(@"Running TTModeNewsPreviousSite");
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

- (void)loadSafari {
    [newsWindowController fadeIn];
    
    SafariApplication *safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
    
    SBElementArray* windows = [safari windows];
    SafariWindow *safariWindow = [windows objectAtIndex:0];
    // This fails when in full-screen mode:
    SafariTab* currentTab = [safariWindow currentTab];
    
    // https://medium.com/the-development-set/the-reductive-seduction-of-other-people-s-problems-3c07b307732d
    [newsWindowController.browserView loadURL:currentTab.URL html:[self readabilityForUrl:currentTab.URL htmlSource:nil] title:currentTab.name];
}

#pragma mark - Menu Options

- (void)runTTModeNewsMenuReturn {
    state = TTModeNewsStateBrowser;
    [newsWindowController.menuView slideOut];
}

- (void)runTTModeNewsMenuNextStory {
    
}

- (void)runTTModeNewsMenuPreviousStory {
    [newsWindowController.browserView.webView goBack];
}

- (void)runTTModeNewsMenuFontSizeUp {
    [newsWindowController.browserView zoomIn];
}

- (void)runTTModeNewsMenuFontSizeDown {
    [newsWindowController.browserView zoomOut];
}

- (void)runTTModeNewsMenuMarginWider {
    [newsWindowController.browserView widenMargin];
}

- (void)runTTModeNewsMenuMarginNarrower {
    [newsWindowController.browserView narrowMargin];
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
