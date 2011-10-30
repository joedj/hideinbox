#import "HideInboxSettings.h"

static BOOL combinedInbox = NO;

%hook MailboxPickerController
- (void)selectCombinedInboxAnimated:(BOOL)animated {
    combinedInbox = YES;
    %orig;
    combinedInbox = NO;
}
%end

%hook MailboxContentViewController
- (void)setMailboxes:(NSSet *)mailboxes {
    if (combinedInbox && mailboxes.count > 1) {
        NSMutableSet *visible = [NSMutableSet set];
        for (id mailbox in mailboxes)
            if (![HideInboxSettings isHidden:[mailbox account].uniqueId])
                [visible addObject:mailbox];
        mailboxes = visible;
    }
    %orig;
}
%end

%hook AccountTableCell
- (void)setAccounts:(NSSet *)accounts {
    if (accounts.count > 1 && [[self reuseIdentifier] isEqualToString:@"MailAccountReuse"]) {
        NSMutableSet *visible = [NSMutableSet set];
        for (Account *account in accounts)
            if (![HideInboxSettings isHidden:account.uniqueId])
                [visible addObject:account];
        accounts = visible;
    }
    %orig;
}
%end

static void settingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    [HideInboxSettings reload];
    id mailboxPickerController = MSHookIvar<id>(UIApplication.sharedApplication, "_mailboxPickerController");
    if (mailboxPickerController) [mailboxPickerController performSelectorOnMainThread:@selector(reload) withObject:nil waitUntilDone:NO];
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &settingsChanged, CFSTR(SETTINGS_CHANGED), NULL, 0);
}
