#import "../Turn Touch Mac/Views/Panel/TTPanelGeometry.h"
#include <assert.h>

int main(void) {
    @autoreleasepool {
        // The reported arrangement: a tall primary display to the left of a
        // shorter right-hand display. Never clamp to the primary display.
        NSRect right = NSMakeRect(1692, 400, 3400, 2000);
        NSRect icon = NSMakeRect(4696, 2400, 22, 22);
        NSRect panel = TTPanelFrameBelowStatusItem(icon, NSMakeSize(380, 691), right, 8);
        assert(NSContainsRect(right, panel));
        assert(NSMidX(panel) == NSMidX(icon));
        assert(NSMaxY(panel) == 2398);

        // Either edge of a display must remain visible while retaining the
        // same vertical anchor, including displays left of the primary.
        NSRect left = NSMakeRect(-1920, -300, 1920, 1058);
        panel = TTPanelFrameBelowStatusItem(NSMakeRect(-30, 758, 22, 22),
                                           NSMakeSize(380, 691), left, 8);
        assert(NSMaxX(panel) == -8 && NSMaxY(panel) == 756);
        panel = TTPanelFrameBelowStatusItem(NSMakeRect(-1918, 758, 22, 22),
                                           NSMakeSize(380, 691), left, 8);
        assert(NSMinX(panel) == -1912 && NSContainsRect(left, panel));

        // Vertically stacked displays use their own top edge, not just height.
        NSRect upper = NSMakeRect(100, 1080, 1920, 1058);
        panel = TTPanelFrameBelowStatusItem(NSMakeRect(800, 2138, 22, 22),
                                           NSMakeSize(380, 691), upper, 8);
        assert(NSMaxY(panel) == 2136 && NSContainsRect(upper, panel));

        // Large content stays within a smaller display's usable area.
        NSRect small = NSMakeRect(0, 40, 800, 538);
        panel = TTPanelFrameBelowStatusItem(NSMakeRect(500, 578, 22, 22),
                                           NSMakeSize(380, 1200), small, 8);
        assert(NSMinY(panel) == 48 && NSMaxY(panel) == 576);
        assert(NSContainsRect(small, panel));
        puts("Panel placement: right, left, staggered, stacked, and small displays passed.");
    }
}
