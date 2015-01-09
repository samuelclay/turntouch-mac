//
//  TTModeHueConnect.m
//  Turn Touch App
//
//  Created by Samuel Clay on 1/8/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTModeHueConnect.h"

@interface TTModeHueConnect ()

@property (nonatomic,weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic,weak) IBOutlet NSTextField *progressMessage;

@end

@implementation TTModeHueConnect


- (void)awakeFromNib {
    [super awakeFromNib];
}


- (void)setLoadingWithMessage:(NSString*)message{
    self.progressMessage.stringValue = message;
    [self.progressIndicator startAnimation:self];
}


@end
