#import <Cocoa/Cocoa.h>

// AppKit screen coordinates can have negative and nonzero origins. Keep the
// panel's top beneath its status item, within that display's usable bounds.
static inline NSRect TTPanelFrameBelowStatusItem(NSRect statusRect, NSSize size,
                                                 NSRect visibleFrame, CGFloat margin) {
    CGFloat left = NSMinX(visibleFrame) + margin;
    CGFloat right = NSMaxX(visibleFrame) - margin;
    CGFloat top = MIN(NSMinY(statusRect) - 2, NSMaxY(visibleFrame));
    CGFloat bottom = NSMinY(visibleFrame) + margin;
    size.width = MIN(size.width, MAX(0, right - left));
    size.height = MIN(size.height, MAX(0, top - bottom));
    CGFloat x = round(NSMidX(statusRect) - size.width / 2);
    return NSMakeRect(MAX(left, MIN(x, right - size.width)),
                      top - size.height, size.width, size.height);
}
