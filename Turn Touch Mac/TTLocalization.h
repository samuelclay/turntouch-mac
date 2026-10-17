#import <Cocoa/Cocoa.h>
FOUNDATION_EXPORT NSString *TTText(NSString *source);
@interface TTLocalization : NSObject
+ (NSArray<NSArray<NSString *> *> *)languages;
+ (NSString *)selection;
+ (NSString *)displayName;
+ (BOOL)needsWelcome;
+ (void)showLanguagePicker;
@end
