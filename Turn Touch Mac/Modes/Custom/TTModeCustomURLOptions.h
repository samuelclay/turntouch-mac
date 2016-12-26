//
//  TTModeCustomOptions.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 12/25/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailViewController.h"

@interface TTModeCustomURLOptions : TTOptionsDetailViewController <NSTextFieldDelegate>

@property (nonatomic) IBOutlet NSTextField *singleUrl;
@property (nonatomic) IBOutlet NSTextField *doubleUrl;
@property (nonatomic) IBOutlet NSTextField *singleLabel;
@property (nonatomic) IBOutlet NSTextField *doubleLabel;
@property (nonatomic) IBOutlet NSButton *singleRefresh;
@property (nonatomic) IBOutlet NSButton *doubleRefresh;
@property (nonatomic) IBOutlet NSProgressIndicator *singleSpinner;
@property (nonatomic) IBOutlet NSProgressIndicator *doubleSpinner;
@property (nonatomic) IBOutlet NSImageView *singleImage;
@property (nonatomic) IBOutlet NSImageView *doubleImage;

- (IBAction)changeUrl:(id)sender;

@end
