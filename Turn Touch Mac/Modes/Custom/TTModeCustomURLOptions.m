//
//  TTModeCustomOptions.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 12/25/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeCustomURLOptions.h"
#import "TTModeCustom.h"

@interface TTModeCustomURLOptions ()

@end

@implementation TTModeCustomURLOptions

@synthesize singleUrl;
@synthesize singleImage;
@synthesize singleLabel;
@synthesize singleRefresh;
@synthesize singleSpinner;
@synthesize doubleUrl;
@synthesize doubleImage;
@synthesize doubleLabel;
@synthesize doubleRefresh;
@synthesize doubleSpinner;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *singleCustomUrl = [self.action optionValue:kSingleCustomUrl
                                             inDirection:appDelegate.modeMap.inspectingModeDirection];
    NSString *doubleCustomUrl = [self.action optionValue:kDoubleCustomUrl
                                             inDirection:appDelegate.modeMap.inspectingModeDirection];
    if (singleCustomUrl) {
        [singleUrl setStringValue:singleCustomUrl];
    }
    if (doubleCustomUrl) {
        [doubleUrl setStringValue:doubleCustomUrl];
    }
    
    singleSpinner.hidden = YES;
    doubleSpinner.hidden = YES;
    
    BOOL singleLastSuccess = [[self.action optionValue:kSingleLastSuccess
                                          inDirection:appDelegate.modeMap.inspectingModeDirection] boolValue];
    BOOL doubleLastSuccess = [[self.action optionValue:kDoubleLastSuccess
                                          inDirection:appDelegate.modeMap.inspectingModeDirection] boolValue];
    
    if ([self.action optionValue:kSingleLastSuccess
                     inDirection:appDelegate.modeMap.inspectingModeDirection] != nil) {
        singleImage.hidden = NO;
        if (singleLastSuccess) {
            singleImage.image = [NSImage imageNamed:@"modal_success"];
        } else {
            singleImage.image = [NSImage imageNamed:@"modal_failure"];
        }
    } else {
        singleImage.hidden = YES;
    }
    
    if ([self.action optionValue:kDoubleLastSuccess
                     inDirection:appDelegate.modeMap.inspectingModeDirection] != nil) {
        doubleImage.hidden = NO;
        if (doubleLastSuccess) {
            doubleImage.image = [NSImage imageNamed:@"modal_success"];
        } else {
            doubleImage.image = [NSImage imageNamed:@"modal_failure"];
        }
    } else {
        doubleImage.hidden = YES;
    }
    
    NSInteger singleHitCount = [[self.action optionValue:kSingleHitCount
                                             inDirection:appDelegate.modeMap.inspectingModeDirection] integerValue];
    NSInteger doubleHitCount = [[self.action optionValue:kDoubleHitCount
                                             inDirection:appDelegate.modeMap.inspectingModeDirection] integerValue];
    if (singleHitCount == 1) {
        singleLabel.stringValue = @"Hit 1 time";
        singleLabel.textColor = [NSColor blackColor];
    } else if (singleHitCount > 1) {
        singleLabel.stringValue = [NSString stringWithFormat:@"Hit %ld times", (long)singleHitCount];
        singleLabel.textColor = [NSColor blackColor];
    } else {
        singleLabel.stringValue = @"Not yet hit";
        singleLabel.textColor = [NSColor lightGrayColor];
    }
    if (doubleHitCount == 1) {
        doubleLabel.stringValue = @"Hit 1 time";
        doubleLabel.textColor = [NSColor blackColor];
    } else if (doubleHitCount > 1) {
        doubleLabel.stringValue = [NSString stringWithFormat:@"Hit %ld times", (long)doubleHitCount];
        doubleLabel.textColor = [NSColor blackColor];
    } else {
        doubleLabel.stringValue = @"Not yet hit";
        doubleLabel.textColor = [NSColor lightGrayColor];
    }
}

- (IBAction)changeUrl:(id)sender {
    NSString *originalSingleUrl = [self.action optionValue:kSingleCustomUrl
                                               inDirection:appDelegate.modeMap.inspectingModeDirection];
    NSString *originalDoubleUrl = [self.action optionValue:kDoubleCustomUrl
                                               inDirection:appDelegate.modeMap.inspectingModeDirection];
    
    if (originalSingleUrl == nil || ![originalSingleUrl isEqualToString:singleUrl.stringValue]) {
        [self.action changeActionOption:kSingleCustomUrl to:singleUrl.stringValue];
        [self.action changeActionOption:kSingleHitCount to:@(0)];
        [self.action changeActionOption:kSingleLastSuccess to:nil];
    }
    if (originalDoubleUrl == nil || ![originalDoubleUrl isEqualToString:doubleUrl.stringValue]) {
        [self.action changeActionOption:kDoubleCustomUrl to:doubleUrl.stringValue];
        [self.action changeActionOption:kDoubleHitCount to:@(0)];
        [self.action changeActionOption:kDoubleLastSuccess to:nil];
    }
}

- (IBAction)hitRefreshSingle:(id)sender {
    [self changeUrl:nil];
    
    singleRefresh.hidden = YES;
    singleSpinner.hidden = NO;
    [singleSpinner startAnimation:nil];
    
    TTModeCustom *customMode = (TTModeCustom *)self.mode;
    [customMode runTTModeCustomURL:appDelegate.modeMap.inspectingModeDirection];
}

- (IBAction)hitRefreshDouble:(id)sender {
    [self changeUrl:nil];

    doubleRefresh.hidden = YES;
    doubleSpinner.hidden = NO;
    [doubleSpinner startAnimation:nil];
    
    TTModeCustom *customMode = (TTModeCustom *)self.mode;
    [customMode doubleRunTTModeCustomURL:appDelegate.modeMap.inspectingModeDirection];
}

- (void)controlTextDidChange:(NSNotification *)obj {
    [self changeUrl:nil];
}

@end
