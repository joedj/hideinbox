TARGET_STRIP = bin/dsym_and_strip "$(SYSROOT)"
TARGET_STRIP_FLAGS = 
ADDITIONAL_CFLAGS += -g

TWEAK_NAME = HideInbox HideInboxPrefs

HideInbox_FILES = HideInbox.xm HideInboxSettings.mm
HideInbox_FRAMEWORKS = UIKit

HideInboxPrefs_FILES = HideInboxPrefs.xmi HideInboxSettings.mm
HideInboxPrefs_PRIVATE_FRAMEWORKS = Preferences

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-stage::
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) \( -iname '*.plist' -or -iname '*.strings' \) -exec plutil -convert binary1 {} \;$(ECHO_END)
