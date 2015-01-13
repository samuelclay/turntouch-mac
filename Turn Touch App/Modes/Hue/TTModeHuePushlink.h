//
//  TTModeHuePushlink.h
//  Turn Touch App
//
//  Created by Samuel Clay on 1/9/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailViewController.h"


/**
 Delegate protocol for this bridge pushlink viewcontroller
 */
@protocol PHBridgePushLinkViewControllerDelegate <NSObject>

@required

/**
 Method which is invoked when the pushlinking was successful
 */
- (void)pushlinkSuccess;

/**
 Method which is invoked when the pushlinking failed
 @param error The error which caused the pushlinking to fail
 */
- (void)pushlinkFailed:(PHError *)error;

@end


@interface TTModeHuePushlink : TTOptionsDetailViewController

@property (nonatomic, unsafe_unretained) id<PHBridgePushLinkViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet NSProgressIndicator *progressView;

/**
 Creates a new instance of this bridge pushlink view controller.
 @param hueSdk the hue sdk instance to use
 @param delegate the delegate to inform when pushlinking is done
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<PHBridgePushLinkViewControllerDelegate>)delegate;

/**
 Start the pushlinking process
 */
- (void)startPushLinking;

@end
