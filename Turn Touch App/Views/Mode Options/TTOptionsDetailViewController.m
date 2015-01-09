//
//  TTOptionsViewController.m
//  Turn Touch App
//
//  Created by Samuel Clay on 1/8/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailViewController.h"

@interface TTOptionsDetailViewController ()

@end

@implementation TTOptionsDetailViewController

@synthesize tabView;
@synthesize menuType;

- (void)viewDidLoad {
    [super viewDidLoad];

    appDelegate = (TTAppDelegate *)[NSApp delegate];
}

@end
