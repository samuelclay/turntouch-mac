//
//  TTModalBarButton.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/10/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTFooterView.h"

@interface TTModalBarButton : TTFooterView

@property (nonatomic) IBOutlet NSTextField *buttonLabel;
@property (nonatomic) IBOutlet NSImageView *chevronImage;

@end
