//
//  TTBatchActionHeaderView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/20/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTBatchActionHeaderView.h"

#define BATCH_ACTION_HEADER_MARGIN 13.f

@implementation TTBatchActionHeaderView

@synthesize mode;
@synthesize batchAction;

- (instancetype)initWithTempMode:(TTMode *)_mode {
    if (self = [super init]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        batchAction = nil;
        mode = _mode;
        
        [self setupLabels];
    }
    
    return self;
}

- (instancetype)initWithBatchAction:(TTBatchAction *)_batchAction {
    if (self = [super init]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        batchAction = _batchAction;
        mode = batchAction.mode;
        
        [self setupLabels];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Background
    [NSColorFromRGB(0xFFFFFF) set];
    NSRectFill(self.bounds);
    
    // Mode image
    NSString *imageFilename = [[mode class] imageName];
    NSString *imagePath = [NSString stringWithFormat:@"%@/icons/%@", [[NSBundle mainBundle] resourcePath], imageFilename];
    modeImage = [[NSImage alloc] initWithContentsOfFile:imagePath];
    
    [modeImage setSize:NSMakeSize(22, 22)];
    CGFloat offset = (NSHeight(self.frame)/2) - (modeImage.size.height/2);
    NSPoint imagePoint = NSMakePoint(BATCH_ACTION_HEADER_MARGIN, offset);
    NSRect imageRect = NSMakeRect(imagePoint.x, imagePoint.y,
                                  modeImage.size.width, modeImage.size.height);
    [modeImage drawInRect:imageRect];
    
    // Mode name
    NSSize titleSize = [[[mode class] title] sizeWithAttributes:titleAttributes];
    NSPoint titlePoint = NSMakePoint(NSMaxX(imageRect) + BATCH_ACTION_HEADER_MARGIN,
                                     NSHeight(self.frame)/2 - floor(titleSize.height/2) + 1);
    
    [[[mode class] title] drawAtPoint:titlePoint withAttributes:titleAttributes];

    if (!batchAction) return;
    
    // Action dropdown
    NSString *actionName = [mode titleForAction:batchAction.action buttonAction:BUTTON_ACTION_PRESSUP];
    NSSize actionSize = [actionName sizeWithAttributes:titleAttributes];
    NSPoint actionPoint = NSMakePoint(NSMinX(self.frame) + BATCH_ACTION_HEADER_MARGIN + 128,
                                      NSHeight(self.frame)/2 - floor(actionSize.height/2) + 1);
    
    [actionName drawAtPoint:actionPoint withAttributes:titleAttributes];
    
    // Delete button
    
}

- (void)setupLabels {
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x404A60);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    titleAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:13],
                        NSForegroundColorAttributeName: textColor,
                        NSShadowAttributeName: stringShadow,
                        NSParagraphStyleAttributeName: style
                        };
}

@end
