//
//  TTModalSettings.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/14/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"

@interface TTModalSettings : NSViewController {
    TTAppDelegate *appDelegate;
}

@property (nonatomic) IBOutlet NSButton *checkboxRecordUsage;

- (IBAction)closeModal:(id)sender;
- (IBAction)changeForm:(id)sender;
@end
