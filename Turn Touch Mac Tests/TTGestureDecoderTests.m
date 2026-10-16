#import <Foundation/Foundation.h>
#import "TTGestureDecoder.h"

static int checks;
static void check(BOOL condition, NSString *message) {
    checks++;
    if (!condition) { NSLog(@"FAIL: %@", message); exit(1); }
}
static NSData *packet(uint8_t down, BOOL held, uint8_t doubleBits) {
    uint8_t bytes[] = {(uint8_t)~(down | doubleBits << 4), held ? 255 : 0};
    return [NSData dataWithBytes:bytes length:2];
}
int main(void) { @autoreleasepool {
    NSMutableArray *events = [NSMutableArray array];
    TTGestureDecoder *decoder = [[TTGestureDecoder alloc] init];
    decoder.onGesture = ^(TTModeDirection direction, TTModeDirection gesture) { [events addObject:@[@(direction), @(gesture)]]; };
    for (int direction = NORTH; direction <= SOUTH; direction++) {
        [events removeAllObjects]; [decoder reset];
        [decoder readData:packet(1 << (direction - NORTH), NO, 0) atTime:1];
        check(decoder.pressedDirection == direction, @"physical direction mapping");
        [decoder readData:packet(0, NO, 0) atTime:1.1];
        [decoder flushAtTime:1.389];
        check(events.count == 0, @"single tap waits for double-tap window");
        [decoder flushAtTime:1.391];
        check([events isEqual:@[@[@(direction), @(SINGLE_TAP)]]], @"single release fires once in the correct direction");
        [decoder flushAtTime:2];
        check(events.count == 1, @"single tap cannot repeat");
    }
    for (int firmware = 0; firmware < 2; firmware++) {
        [decoder reset]; [events removeAllObjects];
        [decoder readData:packet(2, NO, firmware ? 0 : 15) atTime:1];
        [decoder readData:packet(0, NO, firmware ? 0 : 15) atTime:1.05];
        [decoder readData:packet(2, NO, firmware ? 0 : 15) atTime:1.1];
        [decoder readData:packet(0, NO, firmware ? 2 : 15) atTime:1.15];
        [decoder flushAtTime:2];
        check([events isEqual:@[@[@(EAST), @(DOUBLE_TAP)]]], @"firmware and fallback doubles suppress single tap");
    }
    [decoder reset]; [events removeAllObjects];
    [decoder readData:packet(4, NO, 0) atTime:1];
    [decoder readData:packet(4, YES, 0) atTime:1.8];
    [decoder readData:packet(4, YES, 0) atTime:1.9];
    [decoder readData:packet(4, YES, 0) atTime:2.1];
    [decoder readData:packet(0, NO, 0) atTime:2.2];
    [decoder flushAtTime:3];
    check([events isEqual:@[@[@(WEST), @(HOLD)]]], @"hold fires exactly once and suppresses release");
    [decoder reset]; [events removeAllObjects];
    [decoder readData:packet(1, NO, 0) atTime:1];
    [decoder readData:packet(3, NO, 0) atTime:1.1];
    [decoder readData:packet(2, YES, 0) atTime:1.8];
    [decoder readData:packet(0, NO, 0) atTime:2];
    [decoder flushAtTime:3];
    check(events.count == 0, @"chords and their partial releases never execute actions");
    [decoder readData:packet(8, NO, 0) atTime:3];
    [decoder readData:packet(0, NO, 0) atTime:3.1];
    [decoder readData:packet(1, NO, 0) atTime:3.15];
    [decoder readData:packet(0, NO, 0) atTime:3.2];
    [decoder flushAtTime:4];
    check([events isEqual:@[@[@(SOUTH), @(SINGLE_TAP)], @[@(NORTH), @(SINGLE_TAP)]]], @"quick taps on different buttons both fire and recover from chord");
    [decoder reset]; [events removeAllObjects];
    [decoder readData:packet(1, NO, 0) atTime:1];
    [decoder readData:packet(0, NO, 0) atTime:1.1];
    [decoder reset]; [decoder flushAtTime:2];
    check(events.count == 0 && decoder.nextDeadline == 0, @"mode switch or disconnect cancels pending gesture");
    [decoder readData:[NSData data] atTime:3];
    uint8_t byte = 0;
    [decoder readData:[NSData dataWithBytes:&byte length:1] atTime:3];
    check(events.count == 0 && decoder.pressedDirection == NO_DIRECTION, @"malformed packets ignored");
    TTGestureDecoder *other = [[TTGestureDecoder alloc] init];
    other.onGesture = decoder.onGesture;
    for (TTGestureDecoder *remote in @[decoder, other]) {
        [remote readData:packet(1, NO, 0) atTime:4];
        [remote readData:packet(0, NO, 0) atTime:4.1];
    }
    [decoder flushAtTime:5]; [other flushAtTime:5];
    check([events isEqual:@[@[@(NORTH), @(SINGLE_TAP)], @[@(NORTH), @(SINGLE_TAP)]]], @"two remotes cannot combine into a double tap");
    printf("PASS: %d gesture decoder checks\n", checks);
} return 0; }
