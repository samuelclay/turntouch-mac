//
//  TTModeMenuCollectionView.h
//  Turn Touch App
//
//  Created by Samuel Clay on 5/6/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTMenuType.h"
#import "TTAppDelegate.h"

@class TTAppDelegate;

@interface TTModeMenuCollectionView : NSCollectionView {
    TTAppDelegate *appDelegate;
}

@property (nonatomic) TTMenuType menuType;

- (void)setContent:(NSArray *)content withMenuType:(TTMenuType)_menuType;

@end
