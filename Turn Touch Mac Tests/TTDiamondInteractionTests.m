#import <Cocoa/Cocoa.h>
@class TTAppDelegate;
#import "TTDiamondView.h"
#import "TTDiamondLabel.h"
@interface TTDiamondView (Testing)
- (void)drawPaths:(NSRect)rect;
- (TTModeDirection)directionForLocation:(CGPoint)point;
@end
int main(void) { @autoreleasepool {
    [NSApplication sharedApplication];
    NSView *container = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 332, 222)];
    TTDiamondView *diamond = [[TTDiamondView alloc] initWithFrame:container.bounds diamondType:DIAMOND_TYPE_INTERACTIVE];
    [container addSubview:diamond];
    [diamond drawPaths:diamond.bounds];
    TTDiamondLabel *label = [[TTDiamondLabel alloc] initWithFrame:container.bounds inDirection:NORTH];
    [container addSubview:label];
    NSPoint points[] = {{166, 166.5}, {249, 111}, {83, 111}, {166, 55.5}};
    for (TTModeDirection direction = NORTH; direction <= SOUTH; direction++) {
        NSPoint point = points[direction - NORTH];
        NSView *hit = [container hitTest:point];
        if (hit != diamond || [diamond directionForLocation:point] != direction) {
            NSLog(@"FAIL: direction %d hit %@ instead of its diamond", direction, NSStringFromClass(hit.class));
            return 1;
        }
    }
    // Labels also contain an image view; it must not intercept clicks either.
    label.subviews.firstObject.frame = label.bounds;
    if ([container hitTest:points[0]] != diamond) return 1;
    puts("PASS: all four directions receive clicks through labels and their images");
    return 0;
} }
