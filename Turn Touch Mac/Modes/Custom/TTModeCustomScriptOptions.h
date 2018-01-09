//
//  TTModeCustomScript.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 1/9/18.
//  Copyright © 2018 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailViewController.h"

@interface TTModeCustomScriptOptions : TTOptionsDetailViewController <NSTextViewDelegate>

@property (nonatomic) IBOutlet NSTextView *scriptText;

@end
