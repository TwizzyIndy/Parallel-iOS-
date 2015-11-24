include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Parallel
Parallel_FILES = Tweak.xm Zg-Uni-Identifier.m
Parallel_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk

