//
//  TTModeCustomKeyboardOptions.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/1/18.
//  Copyright © 2018 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailViewController.h"

@interface TTModeCustomKeyboardOptions : TTOptionsDetailViewController

@property (nonatomic) IBOutlet NSTextField *singleKey;
@property (nonatomic) IBOutlet NSTextField *doubleKey;

- (IBAction)changeKey:(id)sender;

@end
