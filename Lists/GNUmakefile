include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = Lists
Lists_PRINCIPAL_CLASS = NSApplication

KIT = ../SpecimenKit

Lists_OBJC_FILES = \
	main.m \
	ListsController.m \
	$(KIT)/SpecRegistry.m \
	$(KIT)/SpecStateDump.m \
	$(KIT)/SpecOverlay.m \
	$(KIT)/SpecGrid.m \
	$(KIT)/SpecAppDelegate.m

ADDITIONAL_OBJCFLAGS += -fobjc-arc -I$(KIT) -Wall -Wno-protocol
Lists_OBJC_LIBS += -ldispatch

include $(GNUSTEP_MAKEFILES)/application.make
