//
//  RHAccountsViewController.h
//  RHPreferencesTester
//
//  Created by Richard Heard on 17/04/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RHPreferences.h"

@interface RHAccountsViewController : NSViewController  <RHPreferencesViewControllerProtocol> {
}

@property (assign) IBOutlet NSTextField *usernameTextField;


@end
