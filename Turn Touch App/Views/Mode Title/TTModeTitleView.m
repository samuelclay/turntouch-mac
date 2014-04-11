//
//  TTModeTitleView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 4/10/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTModeTitleView.h"

#define IMAGE_SIZE 32.0f

@implementation TTModeTitleView

@synthesize changeButton;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = [NSApp delegate];

        changeButton = [[NSButton alloc] init];
        [self setChangeButtonTitle:@"change"];
        [changeButton setBezelStyle:NSRoundRectBezelStyle];
        [changeButton setAction:@selector(showChangeModeMenu:)];
        [changeButton setTarget:self];
        [self addSubview:changeButton];
        
        [self registerAsObserver];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self setupTitleAttributes];
    [self drawBackground];
    [self drawBorder];

    modeImage = [NSImage imageNamed:[appDelegate.modeMap.selectedMode imageName]];
    [modeImage setSize:NSMakeSize(IMAGE_SIZE, IMAGE_SIZE)];
    CGFloat offset = (NSHeight(self.frame)/2) - (modeImage.size.height/2);
    NSPoint imagePoint = NSMakePoint(offset, offset);
    [modeImage drawInRect:NSMakeRect(imagePoint.x, imagePoint.y,
                                     modeImage.size.width, modeImage.size.height)];

    NSSize titleSize = [modeTitle sizeWithAttributes:modeAttributes];
    NSPoint titlePoint = NSMakePoint(imagePoint.x + modeImage.size.width + 12,
                                     (NSHeight(self.frame)/2) - (titleSize.height/2));
    [modeTitle drawAtPoint:titlePoint withAttributes:modeAttributes];

    if (isModeChangeActive) {
        NSRect buttonFrame = NSMakeRect(titlePoint.x + 160 + 12,
                                        titlePoint.y + 3, 50, 24);
        [self setChangeButtonTitle:@"cancel"];
        changeButton.frame = buttonFrame;
    } else {
        NSRect buttonFrame = NSMakeRect(titlePoint.x + titleSize.width + 12,
                                        titlePoint.y + 3, 50, 24);
        [self setChangeButtonTitle:@"change"];
        changeButton.frame = buttonFrame;
    }
}

- (void)drawBackground {
    [[NSColor whiteColor] setFill];
    NSRectFill(self.bounds);
}

- (void)drawBorder {
    // Bottom border
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line moveToPoint:NSMakePoint(NSMinX(self.bounds), NSMinY(self.bounds))];
    [line lineToPoint:NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds))];
    [line setLineWidth:1.0];
    [NSColorFromRGB(0xD0D0D0) set];
    [line stroke];
}
#pragma mark - Attributes

- (void)setChangeButtonTitle:(NSString *)title {
    NSMutableParagraphStyle *centredStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [centredStyle setLineHeightMultiple:0.6f];
    [centredStyle setAlignment:NSCenterTextAlignment];
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle,
                           NSParagraphStyleAttributeName,
                           [NSFont fontWithName:@"Helvetica-Bold" size:8.f],
                           NSFontAttributeName,
                           [NSColor whiteColor],
                           NSForegroundColorAttributeName,
                           nil];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
                                                   initWithString:[title uppercaseString] attributes:attrs];
    [changeButton setAttributedTitle:attributedString];
}

- (void)setupTitleAttributes {
    modeTitle = [[appDelegate.modeMap.selectedMode class] description];
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x404A60);
    modeAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Futura" size:13],
                       NSForegroundColorAttributeName: textColor,
                       NSShadowAttributeName: stringShadow
                       };
    textSize = [modeTitle sizeWithAttributes:modeAttributes];
}

#pragma mark - KVO

- (void)registerAsObserver {
    [appDelegate.modeMap addObserver:self forKeyPath:@"selectedMode"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(selectedMode))]) {
        [self setNeedsDisplay:YES];
    }
}

#pragma mark - Events

- (void)showChangeModeMenu:(id)sender {
    if (isModeChangeActive) {
        isModeChangeActive = NO;
        [self setNeedsDisplay:YES];
    } else {
        isModeChangeActive = YES;
        [self setNeedsDisplay:YES];
//        [modeDropdown addItemsWithTitles:appDelegate.modeMap.availableModeTitles];
//        NSInteger selectedIndex = 0;
//        for (NSString *modeClass in appDelegate.modeMap.availableModeClassNames) {
//            if ([modeClass isEqualToString:NSStringFromClass([itemMode class])]) {
//                break;
//            }
//            selectedIndex++;
//        }
//        [modeDropdown selectItemAtIndex:selectedIndex];
    }
}

//- (void)changeModeDropdown:(id)sender {
//    NSString *newModeClassName = [appDelegate.modeMap.availableModeClassNames
//                                  objectAtIndex:[sender indexOfSelectedItem]];
//    [appDelegate.modeMap changeDirection:modeDirection toMode:newModeClassName];
//    isModeChangeActive = NO;
//    [self setupMode];
//    [self setNeedsDisplay:YES];
//}
//
//- (void)hidePopupMenu {
//    if (isModeChangeActive) {
//        isModeChangeActive = NO;
//        [self setNeedsDisplay:YES];
//    }
//}

@end
