#import <Message/Account.h>

#define SETTINGS_CHANGED "net.joedj.hideinbox/SettingsChanged"

@interface HideInboxAccountProvider
- (Account *)account;
@end

@interface HideInboxSettings: NSObject
+ (void)reload;
+ (void)save;
+ (NSNumber *)isHidden:(NSString *)identifier;
+ (void)setHidden:(NSNumber *)hidden forAccount:(id)provider;
@end
