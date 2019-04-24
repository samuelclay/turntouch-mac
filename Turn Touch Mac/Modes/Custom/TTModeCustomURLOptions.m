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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *singleCustomUrl = [self.action optionValue:kSingleCustomUrl
                                             inDirection:self.appDelegate.modeMap.inspectingModeDirection];
    NSString *doubleCustomUrl = [self.action optionValue:kDoubleCustomUrl
                                             inDirection:self.appDelegate.modeMap.inspectingModeDirection];
    if (singleCustomUrl) {
        [self.singleUrl setStringValue:singleCustomUrl];
    }
    if (doubleCustomUrl) {
        [self.doubleUrl setStringValue:doubleCustomUrl];
    }
    
    self.singleSpinner.hidden = YES;
    self.doubleSpinner.hidden = YES;
    
    BOOL singleLastSuccess = [[self.action optionValue:kSingleLastSuccess
                                          inDirection:self.appDelegate.modeMap.inspectingModeDirection] boolValue];
    BOOL doubleLastSuccess = [[self.action optionValue:kDoubleLastSuccess
                                          inDirection:self.appDelegate.modeMap.inspectingModeDirection] boolValue];
    
    if ([self.action optionValue:kSingleLastSuccess
                     inDirection:self.appDelegate.modeMap.inspectingModeDirection] != nil) {
        self.singleImage.hidden = NO;
        if (singleLastSuccess) {
            self.singleImage.image = [NSImage imageNamed:@"modal_success"];
        } else {
            self.singleImage.image = [NSImage imageNamed:@"modal_failure"];
        }
    } else {
        self.singleImage.hidden = YES;
    }
    
    if ([self.action optionValue:kDoubleLastSuccess
                     inDirection:self.appDelegate.modeMap.inspectingModeDirection] != nil) {
        self.doubleImage.hidden = NO;
        if (doubleLastSuccess) {
            self.doubleImage.image = [NSImage imageNamed:@"modal_success"];
        } else {
            self.doubleImage.image = [NSImage imageNamed:@"modal_failure"];
        }
    } else {
        self.doubleImage.hidden = YES;
    }
    
    NSInteger singleHitCount = [[self.action optionValue:kSingleHitCount
                                             inDirection:self.appDelegate.modeMap.inspectingModeDirection] integerValue];
    NSInteger doubleHitCount = [[self.action optionValue:kDoubleHitCount
                                             inDirection:self.appDelegate.modeMap.inspectingModeDirection] integerValue];
    if (singleHitCount == 1) {
        self.singleLabel.stringValue = @"Hit 1 time";
        self.singleLabel.textColor = [NSColor blackColor];
    } else if (singleHitCount > 1) {
        self.singleLabel.stringValue = [NSString stringWithFormat:@"Hit %ld times", (long)singleHitCount];
        self.singleLabel.textColor = [NSColor blackColor];
    } else {
        self.singleLabel.stringValue = @"Not yet hit";
        self.singleLabel.textColor = [NSColor lightGrayColor];
    }
    if (doubleHitCount == 1) {
        self.doubleLabel.stringValue = @"Hit 1 time";
        self.doubleLabel.textColor = [NSColor blackColor];
    } else if (doubleHitCount > 1) {
        self.doubleLabel.stringValue = [NSString stringWithFormat:@"Hit %ld times", (long)doubleHitCount];
        self.doubleLabel.textColor = [NSColor blackColor];
    } else {
        self.doubleLabel.stringValue = @"Not yet hit";
        self.doubleLabel.textColor = [NSColor lightGrayColor];
    }
}

- (IBAction)changeUrl:(id)sender {
    NSString *originalSingleUrl = [self.action optionValue:kSingleCustomUrl
                                               inDirection:self.appDelegate.modeMap.inspectingModeDirection];
    NSString *originalDoubleUrl = [self.action optionValue:kDoubleCustomUrl
                                               inDirection:self.appDelegate.modeMap.inspectingModeDirection];
    
    if (originalSingleUrl == nil || ![originalSingleUrl isEqualToString:self.singleUrl.stringValue]) {
        [self.action changeActionOption:kSingleCustomUrl to:self.singleUrl.stringValue];
        [self.action changeActionOption:kSingleHitCount to:@(0)];
        [self.action changeActionOption:kSingleLastSuccess to:nil];
    }
    if (originalDoubleUrl == nil || ![originalDoubleUrl isEqualToString:self.doubleUrl.stringValue]) {
        [self.action changeActionOption:kDoubleCustomUrl to:self.doubleUrl.stringValue];
        [self.action changeActionOption:kDoubleHitCount to:@(0)];
        [self.action changeActionOption:kDoubleLastSuccess to:nil];
    }
}

- (IBAction)hitRefreshSingle:(id)sender {
    [self changeUrl:nil];
    
    self.singleRefresh.hidden = YES;
    self.singleSpinner.hidden = NO;
    [self.singleSpinner startAnimation:nil];
    
    TTModeCustom *customMode = (TTModeCustom *)self.mode;
    [customMode runTTModeCustomURL:self.appDelegate.modeMap.inspectingModeDirection];
}

- (IBAction)hitRefreshDouble:(id)sender {
    [self changeUrl:nil];

    self.doubleRefresh.hidden = YES;
    self.doubleSpinner.hidden = NO;
    [self.doubleSpinner startAnimation:nil];
    
    TTModeCustom *customMode = (TTModeCustom *)self.mode;
    [customMode doubleRunTTModeCustomURL:self.appDelegate.modeMap.inspectingModeDirection];
}

- (void)controlTextDidChange:(NSNotification *)obj {
    [self changeUrl:nil];
}

@end
