PACKAGE_VERSION = 1.0.3
ARCHS = armv7 armv7s arm64 arm64e
TARGET = iphone:clang:12.1.2:10.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CCArtwork

CCArtwork_FILES = Tweak.x
CCArtwork_PRIVATE_FRAMEWORKS = MediaRemote
CCArtwork_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
