//
//  TTModeTitleView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/10/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTModeTitleView.h"

#define IMAGE_SIZE 32.0f
#define BUTTON_WIDTH 82.0f
#define BUTTON_MARGIN 16.f

@interface TTModeTitleView ()

@property (nonatomic, strong) NSImage *modeImage;
@property (nonatomic, strong) NSString *modeTitle;
@property (nonatomic, strong) NSDictionary *modeAttributes;
@property (nonatomic) CGSize textSize;

@end

@implementation TTModeTitleView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;

        self.changeButton = [[TTChangeButtonView alloc] init];
        [self setChangeButtonTitle:@"Change"];
        [self.changeButton setAction:@selector(showChangeModeMenu:)];
        [self.changeButton setTarget:self];
        [self addSubview:self.changeButton];
        
        [self registerAsObserver];
    }
    return self;
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self setupTitleAttributes];
    [self drawBackground];

    NSString *imageFilename = [[self.appDelegate.modeMap.selectedMode class] imageName];
    self.modeImage = [NSImage imageNamed:imageFilename];

    [self.modeImage setSize:NSMakeSize(IMAGE_SIZE, IMAGE_SIZE)];
    CGFloat offset = (NSHeight(self.frame)/2) - (self.modeImage.size.height/2);
    NSPoint imagePoint = NSMakePoint(offset, offset);
    [self.modeImage drawInRect:NSMakeRect(imagePoint.x, imagePoint.y,
                                     self.modeImage.size.width, self.modeImage.size.height)];

    NSSize titleSize = [self.modeTitle sizeWithAttributes:self.modeAttributes];
    NSPoint titlePoint = NSMakePoint(imagePoint.x + self.modeImage.size.width + 12,
                                     (NSHeight(self.frame)/2) - (titleSize.height/2));
    [self.modeTitle drawAtPoint:titlePoint withAttributes:self.modeAttributes];

    NSRect buttonFrame = NSMakeRect(NSWidth(self.frame) - BUTTON_WIDTH - 12,
                                    (NSHeight(self.frame)/2) - BUTTON_MARGIN,
                                    BUTTON_WIDTH,
                                    NSHeight(self.frame) - BUTTON_MARGIN*2);
    self.changeButton.frame = buttonFrame;
    if (self.appDelegate.modeMap.openedModeChangeMenu) {
        [self setChangeButtonTitle:@"Cancel"];
    } else {
        [self setChangeButtonTitle:@"Change"];
    }
}

- (void)drawBackground {
    [[NSColor whiteColor] setFill];
    NSRectFill(self.bounds);
}

#pragma mark - Attributes

- (void)setChangeButtonTitle:(NSString *)title {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
                                                   initWithString:title attributes:nil];
    [self.changeButton setAttributedTitle:attributedString];
}

- (void)setupTitleAttributes {
    self.modeTitle = [[self.appDelegate.modeMap.selectedMode class] description];
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x404A60);
    self.modeAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:13],
                       NSForegroundColorAttributeName: textColor,
                       NSShadowAttributeName: stringShadow
                       };
    self.textSize = [self.modeTitle sizeWithAttributes:self.modeAttributes];
}

#pragma mark - KVO

- (void)dealloc {
    [self.appDelegate.modeMap removeObserver:self forKeyPath:@"selectedModeDirection"];
    [self.appDelegate.modeMap removeObserver:self forKeyPath:@"openedModeChangeMenu"];
}

- (void)registerAsObserver {
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"selectedModeDirection"
                             options:0 context:nil];
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"openedModeChangeMenu"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(selectedModeDirection))]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(openedModeChangeMenu))]) {
        [self setNeedsDisplay:YES];
    }
}

#pragma mark - Events

- (void)showChangeModeMenu:(id)sender {
    [self.appDelegate.modeMap setOpenedModeChangeMenu:!self.appDelegate.modeMap.openedModeChangeMenu];
    [self.appDelegate.modeMap setInspectingModeDirection:NO_DIRECTION];
    [self setNeedsDisplay:YES];
}

@end
