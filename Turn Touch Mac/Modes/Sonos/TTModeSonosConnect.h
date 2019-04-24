//
//  TTModeSonosConnect.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 7/18/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeSonos.h"
#import "TTOptionsDetailViewController.h"

@interface TTModeSonosConnect : TTOptionsDetailViewController

@property (nonatomic) IBOutlet NSButton *authButton;
@property (nonatomic, strong) TTModeSonos *modeSonos;

- (IBAction)clickAuthButton:(id)sender;

@end
