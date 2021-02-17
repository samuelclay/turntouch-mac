//
//  TTStatusItemView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/20/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTAppDelegate.h"
#import "TTStatusItemView.h"
#import "TTDiamondView.h"
#import "TTBluetoothMonitor.h"

@interface TTStatusItemView ()

@property (nonatomic, strong, readwrite) NSStatusItem *statusItem;

@end

@implementation TTStatusItemView

- (id)initWithStatusItem:(NSStatusItem *)statusItem {
    CGFloat itemWidth = [statusItem length];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
    self = [super initWithFrame:itemRect];
    
    if (self != nil) {
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.statusItem = statusItem;
        self.statusItem.view = self;
        
        NSRect diamondRect = NSInsetRect(itemRect, 4.0f, 3.0f);
        if (@available(macOS 10.16, *)) {
            diamondRect = NSInsetRect(itemRect, 0, 3.0f);
        }
        self.diamondView = [[TTDiamondView alloc] initWithFrame:diamondRect
                                                    diamondType:DIAMOND_TYPE_STATUSBAR];
        [self addSubview:self.diamondView];
    }
    return self;
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
//    NSLog(@"Drawing status item: %@ - %d", NSStringFromRect(dirtyRect), self.isHighlighted);
	[_statusItem drawStatusBarBackgroundInRect:self.bounds
                                 withHighlight:self.isHighlighted];
}

#pragma mark -
#pragma mark Mouse tracking

- (void)mouseDown:(NSEvent *)theEvent {
    [NSApp sendAction:self.action to:self.target from:self];
}

#pragma mark -
#pragma mark Accessors

- (void)setHighlighted:(BOOL)newFlag {
    if (_isHighlighted == newFlag) return;
    _isHighlighted = newFlag;
    [self.diamondView setHighlighted:newFlag];
    [self setNeedsDisplay:YES];
}

#pragma mark -

- (void)setImage:(NSImage *)newImage {
    if (_image != newImage) {
        _image = newImage;
        [self setNeedsDisplay:YES];
    }
}

- (void)setAlternateImage:(NSImage *)newImage {
    if (_alternateImage != newImage) {
        _alternateImage = newImage;
        if (self.isHighlighted) {
            [self setNeedsDisplay:YES];
        }
    }
}

#pragma mark -

- (NSRect)globalRect {
    NSRect frame = [self frame];
    return [self.window convertRectToScreen:frame];

}

@end
