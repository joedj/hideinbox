#import <Preferences/Preferences.h>
#import "HideInboxSettings.h"

static NSArray *insertSpecifier(id provider, NSMutableArray *specifiers) {
    if ([[provider account] isEnabledForDataclass:@"com.apple.Dataclass.Mail"]) {
        PSSpecifier *hideInboxSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Hide Inbox"
                                                       target:provider
                                                       set:@selector(HideInbox_setHidden:)
                                                       get:@selector(HideInbox_isHidden)
                                                       detail:nil
                                                       cell:PSSwitchCell
                                                       edit:nil];
        [hideInboxSpecifier setProperty:@"" forKey:@"hideInboxSpecifier"];
        NSUInteger i = 0;
        for (PSSpecifier *specifier in specifiers) {
            if ([specifier propertyForKey:@"hideInboxSpecifier"]) {
                return specifiers;
            } else if ([[specifier propertyForKey:@"footerCellClass"] isEqualToString:@"AccountSettingsUIDeleteButtonView"]) {
                [specifiers insertObject:hideInboxSpecifier atIndex:i];
                return specifiers;
            }
            i++;
        }
        [specifiers addObject:hideInboxSpecifier];
    }
    return specifiers;
}

static NSNumber *isHidden(id provider) {
    return [HideInboxSettings isHidden:[provider account].identifier];
}

static void setHidden(id provider, NSNumber *hidden) {
    [HideInboxSettings setHidden:hidden forAccount:provider];
    [[provider parentController] reloadSpecifiers];
}

%group MobileMailSettings

%hook AccountPSSyncController
- (NSArray *)specifiers { return insertSpecifier(self, %orig); }
%new - (NSNumber *)HideInbox_isHidden { return isHidden(self); }
%new - (void)HideInbox_setHidden:(NSNumber *)hidden { setHidden(self, hidden); }
%end

%hook AccountPSDetailController
- (NSArray *)specifiers { return insertSpecifier(self, %orig); }
%new - (NSNumber *)HideInbox_isHidden { return isHidden(self); }
%new - (void)HideInbox_setHidden:(NSNumber *)hidden { setHidden(self, hidden); }
%end

%end

%group AppleAccountSettings
%hook AASettingsSyncController
- (NSArray *)specifiers { return insertSpecifier(self, %orig); }
%new - (NSNumber *)HideInbox_isHidden { return isHidden(self); }
%new - (void)HideInbox_setHidden:(NSNumber *)hidden { setHidden(self, hidden); }
%end
%end

%group ActiveSyncSettings
%hook ASSettingsSyncController
- (NSArray *)specifiers { return insertSpecifier(self, %orig); }
%new - (NSNumber *)HideInbox_isHidden { return isHidden(self); }
%new - (void)HideInbox_setHidden:(NSNumber *)hidden { setHidden(self, hidden); }
%end
%end

%hook NSBundle
- (BOOL)load {
    BOOL result = %orig;
    NSString *bundleIdentifier = self.bundleIdentifier;
    if ([bundleIdentifier isEqualToString:@"com.apple.mobilemail.settings"]) %init(MobileMailSettings);
    else if ([bundleIdentifier isEqualToString:@"com.apple.appleaccount.settings"]) %init(AppleAccountSettings);
    else if ([bundleIdentifier isEqualToString:@"com.apple.ActiveSyncSettings"]) %init(ActiveSyncSettings);
    return result;
}
%end

%ctor {
    %init;
}
