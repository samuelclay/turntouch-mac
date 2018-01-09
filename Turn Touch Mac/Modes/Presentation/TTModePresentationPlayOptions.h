//
//  TTModePresentationPlayOptions.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 1/9/18.
//  Copyright © 2018 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailViewController.h"

@interface TTModePresentationPlayOptions : TTOptionsDetailViewController

@property (nonatomic) IBOutlet NSButton *selectFirstSlide;

- (IBAction)selectStartPresentationFirstSlide:(id)sender;

@end
