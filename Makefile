TARGET := iphone:latest:14.0
INSTALL_TARGET_PROCESSES = Instagram

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = IGX

IGX_FILES = Tweak.xm
IGX_CFLAGS = -fobjc-arc -std=gnu++11

include $(THEOS_MAKE_PATH)/tweak.mk
