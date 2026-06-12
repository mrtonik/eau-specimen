include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = Extras
Extras_PRINCIPAL_CLASS = NSApplication

KIT = ../SpecimenKit

Extras_OBJC_FILES = \
	main.m \
	ExtrasController.m \
	$(KIT)/SpecRegistry.m \
	$(KIT)/SpecStateDump.m \
	$(KIT)/SpecOverlay.m \
	$(KIT)/SpecGrid.m \
	$(KIT)/SpecAppDelegate.m

ADDITIONAL_OBJCFLAGS += -fobjc-arc -I$(KIT) -Wall -Wno-protocol
Extras_OBJC_LIBS += -ldispatch

include $(GNUSTEP_MAKEFILES)/application.make
