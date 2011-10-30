#import <notify.h>
#import "HideInboxSettings.h"

#define SETTINGS_FILE (@"~/Library/Preferences/net.joedj.hideinbox.plist".stringByExpandingTildeInPath)

static NSMutableDictionary *settings = nil;

@implementation HideInboxSettings: NSObject

+ (NSMutableDictionary *)settings {
    @synchronized (self) {
        if (!settings) {
            settings = [[NSMutableDictionary alloc] initWithContentsOfFile:SETTINGS_FILE] ?: [[NSMutableDictionary alloc] init];
        }
        return settings;
    }
}

+ (void)reload {
    @synchronized (self) {
        [settings release];
        settings = nil;
    }
}

+ (void)save {
    @synchronized (self) {
        if (settings) {
            NSData *data = [NSPropertyListSerialization dataFromPropertyList:settings format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
            [data writeToFile:SETTINGS_FILE options:NSAtomicWrite error:NULL];
            notify_post(SETTINGS_CHANGED);
        }
    }
}

+ (NSNumber *)isHidden:(NSString *)identifier {
    @synchronized (self) {
        return [self.settings objectForKey:identifier];
    }
}

+ (void)setHidden:(NSNumber *)hidden forAccount:(id)provider {
    NSString *identifier = [provider account].identifier;
    @synchronized (self) {
        if (hidden.boolValue) {
            [self.settings setObject:hidden forKey:identifier];
        } else {
            [self.settings removeObjectForKey:identifier];
        }
        [self save];
    }
}

@end
