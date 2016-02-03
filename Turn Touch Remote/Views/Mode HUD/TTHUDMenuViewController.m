//
//  TTHUDMenuViewController.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/29/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTHUDMenuViewController.h"

@implementation TTHUDMenuViewController

@synthesize menuView;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
//        menuView = (TTHUDMenuView *)self.view;    
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    // Do view setup here.
}

@end
