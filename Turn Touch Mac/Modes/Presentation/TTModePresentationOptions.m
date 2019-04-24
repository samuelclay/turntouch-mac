//
//  TTModePresentationOptions.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 1/8/18.
//  Copyright © 2018 Turn Touch. All rights reserved.
//

#import "TTModePresentationOptions.h"
#import "TTModePresentation.h"

@interface TTModePresentationOptions ()

@end

@implementation TTModePresentationOptions

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSString *app = [self.appDelegate.modeMap mode:self.mode optionValue:kPresentationApp];
    if ([app isEqualToString:@"keynote"]) {
        self.appKeynote.state = NSControlStateValueOn;
    } else if ([app isEqualToString:@"powerpoint"]) {
        self.appPowerpoint.state = NSControlStateValueOn;
    }
}

- (IBAction)selectApp:(id)sender {
    if (self.appKeynote.state == NSControlStateValueOn) {
        [self.appDelegate.modeMap changeMode:self.mode option:kPresentationApp to:@"keynote"];
    } else if (self.appPowerpoint.state == NSControlStateValueOn) {
        [self.appDelegate.modeMap changeMode:self.mode option:kPresentationApp to:@"powerpoint"];
    }
}

@end
