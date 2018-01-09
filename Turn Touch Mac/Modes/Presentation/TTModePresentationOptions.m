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

@synthesize appKeynote;
@synthesize appPowerpoint;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSString *app = [appDelegate.modeMap mode:self.mode optionValue:kPresentationApp];
    if ([app isEqualToString:@"keynote"]) {
        appKeynote.state = NSControlStateValueOn;
    } else if ([app isEqualToString:@"powerpoint"]) {
        appPowerpoint.state = NSControlStateValueOn;
    }
}

- (IBAction)selectApp:(id)sender {
    if (appKeynote.state == NSControlStateValueOn) {
        [appDelegate.modeMap changeMode:self.mode option:kPresentationApp to:@"keynote"];
    } else if (appPowerpoint.state == NSControlStateValueOn) {
        [appDelegate.modeMap changeMode:self.mode option:kPresentationApp to:@"powerpoint"];
    }
}

@end
