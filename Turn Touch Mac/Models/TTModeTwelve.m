#import "TTModeTwelve.h"

@implementation TTModeTwelve
+ (NSString *)title { return TTText(@"12 actions"); }
+ (NSString *)description { return TTText(@"Choose a button, then add an action"); }
+ (NSString *)imageName { return @"settings"; }
- (NSArray *)actions { return @[]; }
- (BOOL)hideActionMenu { return YES; }
- (void)runDirection:(TTModeDirection)direction {}
- (BOOL)shouldFireImmediateOnPress:(TTModeDirection)direction { return NO; }
- (BOOL)shouldIgnoreSingleBeforeDouble:(TTModeDirection)direction { return NO; }
- (NSString *)actionNameInDirection:(TTModeDirection)direction { return @"TTGestureAction"; }
- (NSString *)titleInDirection:(TTModeDirection)direction buttonMoment:(TTButtonMoment)moment {
    NSArray<TTAction *> *actions = [self.appDelegate.modeMap selectedModeBatchActions:direction];
    TTAction *first = actions.firstObject;
    if (!first) return TTText(@"Add action");
    NSString *title = [first.mode titleForAction:first.actionName buttonMoment:BUTTON_MOMENT_PRESSUP];
    return actions.count > 1 ? [NSString stringWithFormat:@"%@ +%lu", title, (unsigned long)actions.count - 1] : title;
}
- (NSString *)imageNameInDirection:(TTModeDirection)direction {
    TTAction *first = [self.appDelegate.modeMap selectedModeBatchActions:direction].firstObject;
    return first ? [first.mode.class imageName] : @"settings";
}
@end
