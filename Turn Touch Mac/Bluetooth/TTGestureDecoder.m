#import "TTGestureDecoder.h"

static const NSTimeInterval DoubleTapWindow = 0.290;
@implementation TTGestureDecoder {
    uint8_t _previousBits, _heldBits;
    BOOL _chord;
    TTModeDirection _pending;
    NSTimeInterval _pendingTime;
}
- (NSTimeInterval)nextDeadline { return _pending ? _pendingTime + DoubleTapWindow : 0; }
- (void)reset {
    _previousBits = _heldBits = 0;
    _chord = NO;
    _pending = NO_DIRECTION;
    _pressedDirection = NO_DIRECTION;
}
- (void)emit:(TTModeDirection)direction gesture:(TTModeDirection)gesture {
    if (self.onGesture) self.onGesture(direction, gesture);
}
- (void)flushAtTime:(NSTimeInterval)now {
    if (_pending && now >= self.nextDeadline) {
        TTModeDirection direction = _pending;
        _pending = NO_DIRECTION;
        [self emit:direction gesture:SINGLE_TAP];
    }
}
- (void)readData:(NSData *)data atTime:(NSTimeInterval)now {
    if (data.length < 2) return;
    [self flushAtTime:now];
    const uint8_t *bytes = data.bytes;
    uint8_t bits = ~bytes[0] & 15;
    uint8_t doubleBits = (~bytes[0] >> 4) & 15;
    if (__builtin_popcount(bits) > 1) { _chord = YES; _pending = NO_DIRECTION; }
    if (_chord) {
        _previousBits = bits;
        _pressedDirection = NO_DIRECTION;
        if (!bits) { _chord = NO; _heldBits = 0; }
        return;
    }
    _pressedDirection = bits ? (TTModeDirection)(__builtin_ctz(bits) + NORTH) : NO_DIRECTION;
    if (bytes[1] == 255 && bits && !(_heldBits & bits)) {
        _pending = NO_DIRECTION;
        _heldBits |= bits;
        [self emit:self.pressedDirection gesture:HOLD];
    }
    uint8_t lifted = _previousBits & ~bits & 15;
    for (int i = 0; i < 4; i++) {
        if (!(lifted & (1 << i)) || (_heldBits & (1 << i))) continue;
        TTModeDirection direction = (TTModeDirection)(NORTH + i);
        if ((doubleBits && doubleBits != 15) || (_pending == direction && now - _pendingTime < DoubleTapWindow)) {
            _pending = NO_DIRECTION;
            [self emit:direction gesture:DOUBLE_TAP];
        } else {
            if (_pending) [self emit:_pending gesture:SINGLE_TAP];
            _pending = direction;
            _pendingTime = now;
        }
    }
    _heldBits &= bits;
    _previousBits = bits;
}
@end
