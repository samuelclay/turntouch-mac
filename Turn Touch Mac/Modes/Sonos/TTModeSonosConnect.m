//
//  TTModeSonosConnect.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 7/18/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeSonosConnect.h"

@interface TTModeSonosConnect ()

@end

@implementation TTModeSonosConnect

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark - Actions

- (IBAction)clickAuthButton:(id)sender {
    [self.modeSonos beginConnectingToSonos:nil];
}


@end
