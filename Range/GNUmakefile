include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = Range
Range_PRINCIPAL_CLASS = NSApplication

KIT = ../SpecimenKit

Range_OBJC_FILES = \
	main.m \
	RangeController.m \
	$(KIT)/SpecRegistry.m \
	$(KIT)/SpecStateDump.m \
	$(KIT)/SpecOverlay.m \
	$(KIT)/SpecGrid.m \
	$(KIT)/SpecAppDelegate.m

ADDITIONAL_OBJCFLAGS += -fobjc-arc -I$(KIT) -Wall
Range_OBJC_LIBS += -ldispatch

include $(GNUSTEP_MAKEFILES)/application.make
